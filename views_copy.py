import calendar
import logging
 
from braces.views import JSONResponseMixin
from dateutil import parser
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.contrib.auth.mixins import LoginRequiredMixin
from django.contrib.gis.geos import Point
from django.contrib.messages.views import SuccessMessageMixin
from django.db.models import Q
from django.http import HttpResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse_lazy
from django.utils.translation import gettext_lazy as _
from django.views import View
from django.views.generic import (
    CreateView,
    DeleteView,
    DetailView,
    ListView,
    UpdateView,
)
from django.views.generic.edit import FormView
from django_tables2 import RequestConfig

from core.forms import DateTimeFilterInlineForm, DateTimeFilterForm
from core.mixins import CompanyLocalizedFormMixin, CompanyMixin
from core.mixins import ManagerRequiredMixin, StaffRequiredMixin
from front.decorators import manager_required, staff_required
from front.utils import get_user_company
from .forms import *
from .models import Region, TraccarDevice
from .serializers import NotificationSerializer
from .tables import NotificationTable, TrackTable
from .tasks import (
    traccardevice_enable_parking,
    traccardevice_enable_geofence,
    traccardevice_disable_parking,
    traccardevice_disable_geofence,
)
from .utils import (
    get_default_notifications,
    get_custom_notifications,
    get_advanced_notifications,
    send_position_notification,
    send_raw_notification,
)

logger = logging.getLogger(__name__)


# region TraccarTrack


class TraccarTrackDetail(LoginRequiredMixin, ManagerRequiredMixin, DetailView):
    model = TraccarTrack
    template_name = "tracking/traccartrack_detail.html"
    form_class = DateTimeFilterForm

    def get_context_data(self, **kwargs):
        initial = super(TraccarTrackDetail, self).get_context_data(**kwargs)
        initial.update(
            {
                "device": self.object.rule.device,
                "positions_count": self.object.positions.count(),
                "positions": self.object.geojson(),
                "color": self.object.rule.color,
                "form_no_positions": DateTimeFilterInlineForm(
                    initial={
                        "datetime_start": self.object.datetime_start,
                        "datetime_end": self.object.datetime_end,
                    }
                ),
                "form": DateTimeFilterForm(
                    initial={
                        "datetime_start": self.object.datetime_start,
                        "datetime_end": self.object.datetime_end,
                    }
                ),
            }
        )

        return initial


class TraccarTrackUpdate(
    LoginRequiredMixin, ManagerRequiredMixin, CompanyMixin, FormView
):
    model = TraccarTrack
    form_class = DateTimeFilterForm

    def form_valid(self, form):
        if not form.is_valid():
            return super(TraccarTrackUpdate, self).form_valid(form)

        datetime_start = form.cleaned_data["datetime_start"]
        datetime_end = form.cleaned_data["datetime_end"]

        device = get_object_or_404(
            TraccarDevice, pk=self.kwargs.get("device_id", None), company=self.company
        )
        track = TraccarTrack.objects.get(
            pk=self.kwargs.get("pk"), rule__device__company=self.company
        )

        to_remove_start = track.positions.filter(fix_time__lt=datetime_start)
        to_remove_end = track.positions.filter(fix_time__gt=datetime_end)

        to_add = TraccarPosition.objects.filter(
            traccartrack=None,
            device=device,
            fix_time__gte=datetime_start,
            fix_time__lte=datetime_end,
        )
        track.positions.remove(*to_remove_start)
        track.positions.remove(*to_remove_end)

        track.datetime_start = form.cleaned_data["datetime_start"]
        track.datetime_end = form.cleaned_data["datetime_end"]
        track.positions.add(*to_add)
        track.save()

        messages.success(self.request, _("Track updated."))

        return redirect(
            reverse_lazy("tracking:traccartrack_detail", kwargs=self.kwargs)
        )


# endregion


@login_required
def index(request):
    return render(request, "tracking/index.html")


@login_required()
def traccar_winter_services(request):
    datetime_now = timezone.now()

    datetime_start_default = datetime(datetime_now.year, datetime_now.month, 1, 0, 0, 0)
    datetime_end_default = datetime(
        datetime_now.year,
        datetime_now.month,
        calendar.monthrange(datetime_now.year, datetime_now.month)[1],
        23,
        59,
        59,
    )

    datetime_start = datetime_start_default
    datetime_end = datetime_end_default

    if request.method == "POST":
        form = DateTimeFilterInlineForm(request.POST)
        if form.is_valid():
            datetime_start = form.cleaned_data["datetime_start"]
            datetime_end = form.cleaned_data["datetime_end"]
    else:
        form = DateTimeFilterInlineForm(
            initial={"datetime_start": datetime_start, "datetime_end": datetime_end}
        )

    company = get_user_company(request.user)
    devices = TraccarDevice.objects.filter(company=company, type=TraccarDevice.WINTER)
    for device in devices:
        device.tracks = TraccarTrack.objects.filter(
            rule__device=device,
            datetime_start__gte=datetime_start,
            datetime_start__lte=datetime_end,
        ).exclude(datetime_end=None)
        device.total_hourly_cost = 0.0
        device.total_distance_cost = 0.0
        for track in device.tracks:
            if track.datetime_end:
                if not track.deleted:
                    device.total_hourly_cost = round(
                        device.total_hourly_cost + track.total_hourly_cost(), 2
                    )
                    device.total_distance_cost = round(
                        device.total_distance_cost + track.total_distance_cost(), 2
                    )

    return render(
        request,
        "tracking/traccar_winter_services.html",
        {
            "form": form,
            "devices": devices,
            "datetime_start": datetime_start,
            "datetime_end": datetime_end,
        },
    )


@login_required()
def notificationrule_test(request, device_pk):
    device = get_object_or_404(TraccarDevice, pk=device_pk)
    notifications = list()
    if request.method == "POST":
        form = NotificationRuleTestForm(request.POST)
        if not form.is_valid():
            return
        json_data = json.loads(form.cleaned_data["payload"])
        json_position = json_data.get("position", None)
        str_fix_time = json_position.get("fixTime", None)
        fix_time = parser.parse(str_fix_time)
        latitude = json_position.get("latitude", None)
        longitude = json_position.get("longitude", None)
        coordinates = Point(x=longitude, y=latitude)
        position = TraccarPosition()
        position.device = device
        position.raw = json_data
        position.fix_time = fix_time
        position.coordinates = coordinates
        default_notifications = get_default_notifications(position)
        custom_notifications = get_custom_notifications(position)
        advanced_notifications = get_advanced_notifications(position)
        if form.cleaned_data["send_notifications"]:
            for rule, triggered in default_notifications:
                if triggered:
                    send_position_notification(position, rule.type, test=True)
            for rule, value, triggered in custom_notifications:
                if triggered:
                    notification = Notification.create(
                        rule=rule,
                        datetime=position.fix_time,
                        position=position,
                        value=value,
                        test=True,
                    )
                    send_raw_notification(notification, test=True)
            for rule, triggered in advanced_notifications:
                if triggered:
                    notification = Notification.create(
                        rule=rule,
                        datetime=position.fix_time,
                        position=position,
                        value=None,
                        test=True,
                    )
                    send_raw_notification(notification, test=True)
        notifications += default_notifications
        notifications += custom_notifications
        notifications += advanced_notifications
        print(notifications)
    else:

        json_string = json.dumps(device.last_update_raw, indent=True)
        form = NotificationRuleTestForm(initial={"payload": json_string})

    return render(
        request,
        "tracking/notificationrule_test.html",
        {"form": form, "device": device, "notifications": notifications},
    )


# region Device


class TraccarDeviceList(LoginRequiredMixin, ListView):
    template_name = "tracking/traccardevice_list.html"
    paginate_by = 20

    def get_queryset(self):
        return TraccarDevice.objects.filter(company=get_user_company(self.request.user))

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        return context


@login_required
@staff_required
def traccardevice_assign(request):
    template_name = "tracking/traccardevice_assign_form.html"
    if request.method == "POST":
        form = TraccarDeviceAssignForm(request.POST, request.FILES)
        if form.is_valid():
            device = form.cleaned_data["traccardevice"]
            device.company = form.cleaned_data["company"]
            device.save()
            messages.success(request, _("Device assigned successfully."))
            return redirect("tracking:traccardevice_assign")
        else:
            for error in form.errors:
                messages.error(request, error)
    else:
        form = TraccarDeviceAssignForm()
    return render(request, template_name, {"form": form})


class TraccarDeviceNotification(
    LoginRequiredMixin, CompanyMixin, JSONResponseMixin, View
):
    http_method_names = ["get"]

    def get(self, request, *args, **kwargs):
        device = get_object_or_404(
            TraccarDevice, pk=self.kwargs["pk"], company=self.company
        )

        predicate = Q(device=device)
        if "from" in request.GET:
            start = datetime.fromtimestamp(int(request.GET["from"]), tz=timezone.utc)
            predicate &= Q(datetime__gte=start)
        if "to" in request.GET:
            end = datetime.fromtimestamp(int(request.GET["to"]), tz=timezone.utc)
            predicate &= Q(datetime__lte=end)

        notifications = Notification.objects.filter(predicate).order_by("-datetime")
        json_data = NotificationSerializer(notifications, many=True).data
        return HttpResponse(
            json.dumps({"data": json_data}), content_type=self.get_content_type()
        )


@login_required
def traccardevice_detail(request, pk):
    company = get_user_company(request.user)
    device = get_object_or_404(TraccarDevice, pk=pk, company=company)

    url, height = device.get_metrics_url(company)
    if url:
        return render(
            request,
            "tracking/traccardevice_detail_grafana.html",
            {
                "object": device,
                "grafana_url": url,
                "grafana_height": height,
            },
        )

    datetime_end = None
    datetime_start = None
    time_filter = "12h"

    if request.method == "POST":
        form = DateTimeFilterInlineForm(request.POST)
        if form.is_valid():
            datetime_start = form.cleaned_data["datetime_start"]
            datetime_end = form.cleaned_data["datetime_end"]
        else:
            messages.error(request, _("Please select a valid start/end date and time"))
    else:
        datetime_end = datetime.now()
        time_filter = request.GET.get("filter")
        if time_filter == "1h":
            delta = timedelta(hours=1)
        elif time_filter == "12h":
            delta = timedelta(hours=12)
        elif time_filter == "24h":
            delta = timedelta(hours=24)
        elif time_filter == "48h":
            delta = timedelta(hours=48)
        elif time_filter == "7d":
            delta = timedelta(days=7)
        elif time_filter == "1m":
            delta = timedelta(days=31)
        else:
            delta = timedelta(hours=12)
        datetime_start = datetime_end - delta
        form = DateTimeFilterInlineForm(
            initial={"datetime_start": datetime_start, "datetime_end": datetime_end}
        )

    notification_table = NotificationTable(
        data=Notification.objects.filter(
            device=device, datetime__gte=datetime_start, datetime__lte=datetime_end
        )
    )
    RequestConfig(request, paginate={"per_page": 10}).configure(notification_table)

    qs = TraccarTrack.objects.filter(
        rule__device=device,
        datetime_start__lte=datetime_end,
        datetime_end__gte=datetime_start,
    ) | TraccarTrack.objects.filter(
        rule__device=device, datetime_start__lte=datetime_end, datetime_end=None
    )
    track_table = TrackTable(data=qs)
    RequestConfig(request, paginate={"per_page": 10}).configure(track_table)

    regions = Region.objects.filter(company=get_user_company(request.user))
    charts = Chart.objects.filter(device=device)

    return render(
        request,
        "tracking/traccardevice_detail.html",
        {
            "object": device,
            "form": form,
            "time_filter": time_filter,
            "notification_table": notification_table,
            "track_table": track_table,
            "datetime_start": datetime_start,
            "datetime_end": datetime_end,
            "regions": regions,
            "charts": charts,
        },
    )


@login_required
def traccardevice_parking_enable(request, pk, when):
    device = get_object_or_404(
        TraccarDevice, pk=pk, company=get_user_company(request.user)
    )
    if when == "later":
        traccardevice_enable_parking(device, True)
        messages.warning(
            request, _("Parking will be active active after next location update.")
        )
    else:
        traccardevice_enable_parking(device, False)
        messages.info(request, _("Parking is active."))

    return redirect("tracking:traccardevice_detail", pk=device.pk)


@login_required
def traccardevice_parking_disable(request, pk):
    device = get_object_or_404(
        TraccarDevice, pk=pk, company=get_user_company(request.user)
    )
    traccardevice_disable_parking(device)
    messages.warning(request, _("Parking is not active."))
    return redirect("tracking:traccardevice_detail", pk=device.pk)


@login_required
def traccardevice_geofence_enable(request, pk, region_pk):
    device = get_object_or_404(
        TraccarDevice, pk=pk, company=get_user_company(request.user)
    )
    region = get_object_or_404(
        Region, pk=region_pk, company=get_user_company(request.user)
    )
    traccardevice_enable_geofence(device, region, False)
    messages.info(request, _("Geofence is active."))
    return redirect("tracking:traccardevice_detail", pk=device.pk)


@login_required
def traccardevice_geofence_disable(request, pk):
    device = get_object_or_404(
        TraccarDevice, pk=pk, company=get_user_company(request.user)
    )
    traccardevice_disable_geofence(device)
    messages.warning(request, _("Geofence is not active."))
    return redirect("tracking:traccardevice_detail", pk=device.pk)


class TraccarDeviceSettings(
    LoginRequiredMixin,
    CompanyMixin,
    ManagerRequiredMixin,
    SuccessMessageMixin,
    UpdateView,
):
    model = TraccarDevice
    form_class = TraccarDeviceSettingsForm
    template_name = "tracking/traccardevice_settings.html"
    success_message = _("Device updated.")

    def get_context_data(self, **kwargs):
        context = super(TraccarDeviceSettings, self).get_context_data(**kwargs)
        context["object"] = get_object_or_404(
            TraccarDevice, pk=self.kwargs.get("pk"), company=self.company
        )
        return context

    def get_form(self, form_class=None):
        form = super(TraccarDeviceSettings, self).get_form(form_class)
        form.fields["user"].queryset = User.objects.filter(
            companyuser__company=self.company, companyuser__is_external=False
        ).order_by("first_name", "last_name")
        return form

    def get_success_url(self):
        return reverse_lazy(
            "tracking:traccardevice_settings", kwargs={"pk": self.kwargs.get("pk")}
        )


# endregion


# region ChartTemplate


class ChartTemplateList(LoginRequiredMixin, StaffRequiredMixin, ListView):
    template_name = "tracking/charttemplate_list.html"
    paginate_by = 10

    def get_queryset(self):
        return ChartTemplate.objects.all()


class ChartTemplateCreate(
    LoginRequiredMixin, StaffRequiredMixin, SuccessMessageMixin, CreateView
):
    model = ChartTemplate
    form_class = ChartTemplateForm
    template_name = "tracking/charttemplate_form.html"
    success_message = _("Chart template created.")

    def get_success_url(self):
        return reverse_lazy("tracking:charttemplate_list")


class ChartTemplateUpdate(
    LoginRequiredMixin, StaffRequiredMixin, SuccessMessageMixin, UpdateView
):
    model = ChartTemplate
    form_class = ChartTemplateForm
    template_name = "tracking/charttemplate_form.html"
    success_message = _("Chart template updated.")

    def get_success_url(self):
        return reverse_lazy("tracking:charttemplate_list")


class ChartTemplateDelete(
    LoginRequiredMixin, StaffRequiredMixin, SuccessMessageMixin, DeleteView
):
    model = ChartTemplate
    template_name = "tracking/charttemplate_confirm_delete.html"
    success_message = _("Chart template deleted.")

    def get_success_url(self):
        return reverse_lazy("tracking:charttemplate_list")


# endregion


# region TrackRuleTemplate


class TraccarTrackRuleTemplateList(LoginRequiredMixin, StaffRequiredMixin, ListView):
    template_name = "tracking/traccartrackruletemplate_list.html"
    paginate_by = 10

    def get_queryset(self):
        return TraccarTrackRuleTemplate.objects.all()


class TraccarTrackRuleTemplateCreate(
    LoginRequiredMixin, StaffRequiredMixin, SuccessMessageMixin, CreateView
):
    model = TraccarTrackRuleTemplate
    form_class = TraccarTrackRuleTemplateForm
    template_name = "tracking/traccartrackruletemplate_form.html"
    success_message = _("Track rule template created.")

    def get_success_url(self):
        return reverse_lazy("tracking:traccartrackruletemplate_list")


class TraccarTrackRuleTemplateUpdate(
    LoginRequiredMixin, StaffRequiredMixin, SuccessMessageMixin, UpdateView
):
    model = TraccarTrackRuleTemplate
    form_class = TraccarTrackRuleTemplateForm
    template_name = "tracking/traccartrackruletemplate_form.html"
    success_message = _("Track rule template updated.")

    def get_success_url(self):
        return reverse_lazy("tracking:traccartrackruletemplate_list")


class TraccarTrackRuleTemplateDelete(
    LoginRequiredMixin, StaffRequiredMixin, SuccessMessageMixin, DeleteView
):
    model = TraccarTrackRuleTemplate
    template_name = "tracking/traccartrackruletemplate_confirm_delete.html"
    success_message = _("Track rule template deleted.")

    def get_success_url(self):
        return reverse_lazy("tracking:traccartrackruletemplate_list")


# endregion


# region NotificationRuleTemplate


class NotificationRuleTemplateList(LoginRequiredMixin, StaffRequiredMixin, ListView):
    template_name = "tracking/notificationruletemplate_list.html"
    paginate_by = 10

    def get_queryset(self):
        return NotificationRuleTemplate.objects.all()


class NotificationRuleTemplateCreate(
    LoginRequiredMixin,
    StaffRequiredMixin,
    SuccessMessageMixin,
    CompanyLocalizedFormMixin,
    CreateView,
):
    model = NotificationRuleTemplate
    form_class = NotificationRuleTemplateForm
    template_name = "tracking/notificationruletemplate_form.html"
    success_message = _("Notification rule template created.")

    def get_success_url(self):
        return reverse_lazy("tracking:notificationruletemplate_list")


class NotificationRuleTemplateUpdate(
    LoginRequiredMixin,
    StaffRequiredMixin,
    SuccessMessageMixin,
    CompanyLocalizedFormMixin,
    UpdateView,
):
    model = NotificationRuleTemplate
    form_class = NotificationRuleTemplateForm
    template_name = "tracking/notificationruletemplate_form.html"
    success_message = _("Notification rule template updated.")

    def get_success_url(self):
        return reverse_lazy("tracking:notificationruletemplate_list")


class NotificationRuleTemplateDelete(
    LoginRequiredMixin, StaffRequiredMixin, SuccessMessageMixin, DeleteView
):
    model = NotificationRuleTemplate
    template_name = "tracking/notificationruletemplate_confirm_delete.html"
    success_message = _("Notification rule template deleted.")

    def get_success_url(self):
        return reverse_lazy("tracking:notificationruletemplate_list")


@login_required
@staff_required
def notificationruletemplate_duplicate(request, pk):
    item = get_object_or_404(NotificationRuleTemplate, pk=pk)
    item.pk = None
    item.name = item.name + (" [%s]" % _("copy")).upper()
    item.save()
    messages.info(request, _("Notification rule template %s duplicated.") % item.name)
    return redirect("tracking:notificationruletemplate_list")


# endregion


# region NotificationRule
@login_required
@manager_required
def notificationrule_import(request, device_pk):
    device = get_object_or_404(
        TraccarDevice, pk=device_pk, company=get_user_company(request.user)
    )
    if request.method == "POST":
        form = ImportNotificationRuleForm(request.POST, request.FILES)
        if form.is_valid():
            group = form.cleaned_data["group"]
            for template in NotificationRuleTemplate.objects.all():
                rule = NotificationRule()
                for field in rule._meta.fields:
                    value = getattr(template, field.name, None)
                    if value:
                        setattr(rule, field.name, value)
                rule.device = device
                rule.notification_group = group
                rule.save()
            messages.success(request, _("Notification rules imported successfully."))
            return redirect("tracking:notificationrule_list", device_pk=device_pk)
    else:
        form = ImportNotificationRuleForm()
        form.fields["group"].queryset = CompanyGroup.objects.filter(
            company=get_user_company(request.user)
        )
    return render(
        request,
        "tracking/notificationrule_import.html",
        {"form": form, "device": device},
    )


@login_required
@manager_required
def notificationrule_create_from_template(request, device_pk):
    device = get_object_or_404(
        TraccarDevice, pk=device_pk, company=get_user_company(request.user)
    )
    if request.method == "POST":
        form = CreateNotificationRuleFromTemplateForm(request.POST, request.FILES)
        if form.is_valid():
            template = form.cleaned_data["template"]
            rule = NotificationRule()
            for field in rule._meta.fields:
                value = getattr(template, field.name, None)
                if value:
                    setattr(rule, field.name, value)
            rule.device = device
            rule.id = None
            rule.save()
            messages.success(request, _("Notification rule created successfully."))
            return redirect("tracking:notificationrule_list", device_pk=device_pk)
    else:
        form = CreateNotificationRuleFromTemplateForm()
        # form.fields['template'].queryset = TrackRuleTemplate.objects.filter(company=get_user_company(request.user))
    return render(
        request,
        "tracking/notificationrule_create_from_template.html",
        {"form": form, "device": device},
    )


@login_required
@manager_required
def notificationrule_detrigger(request, device_pk, pk):
    notification_rule = get_object_or_404(
        NotificationRule, pk=pk, device__company=get_user_company(request.user)
    )
    notification_rule.triggered = False
    notification_rule.save()
    messages.info(
        request, _('Notification rule "%s" detriggered.' % notification_rule.name)
    )
    return redirect("tracking:notificationrule_list", device_pk=device_pk)


@login_required
def notificationrule_duplicate(request, device_pk, pk):
    item = get_object_or_404(NotificationRule, pk=pk)
    item.pk = None
    item.name = item.name + (" [%s]" % _("copy")).upper()
    item.save()
    messages.info(request, _("Notification rule %s duplicated.") % item.name)
    return redirect("tracking:notificationrule_list", device_pk=device_pk)


class NotificationRuleList(LoginRequiredMixin, ListView):
    template_name = "tracking/notificationrule_list.html"
    paginate_by = 10

    def get_queryset(self):
        return NotificationRule.objects.filter(
            device__company=get_user_company(self.request.user),
            device__pk=self.kwargs.get("device_pk"),
        )

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(NotificationRuleList, self).get_context_data(**kwargs)
        context["device"] = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        return context


class NotificationRuleCreate(
    LoginRequiredMixin,
    ManagerRequiredMixin,
    SuccessMessageMixin,
    CompanyLocalizedFormMixin,
    CreateView,
):
    model = NotificationRule
    form_class = NotificationRuleForm
    template_name = "tracking/notificationrule_form.html"
    success_message = _("Notification rule created.")

    def get_context_data(self, **kwargs):
        context = super(NotificationRuleCreate, self).get_context_data(**kwargs)
        context["device"] = self.device
        context["last_position"] = TraccarPosition.objects.filter(
            device=self.device
        ).first()
        return context

    def get_form(self, form_class=None):
        form = super(NotificationRuleCreate, self).get_form(form_class)
        form.fields["notification_group"].queryset = CompanyGroup.objects.filter(
            company=get_user_company(self.request.user)
        ).all()
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        return form

    def get_success_url(self):
        return reverse_lazy(
            "tracking:notificationrule_list",
            kwargs={"device_pk": self.kwargs.get("device_pk")},
        )

    def form_valid(self, form):
        form.instance.device = self.device
        return super(NotificationRuleCreate, self).form_valid(form)


class NotificationRuleUpdate(
    LoginRequiredMixin,
    ManagerRequiredMixin,
    SuccessMessageMixin,
    CompanyLocalizedFormMixin,
    UpdateView,
):
    model = NotificationRule
    form_class = NotificationRuleForm
    template_name = "tracking/notificationrule_form.html"
    success_message = _("Notification rule updated.")

    def get_form(self, form_class=None):
        form = super(NotificationRuleUpdate, self).get_form(form_class)
        form.fields["notification_group"].queryset = CompanyGroup.objects.filter(
            company=get_user_company(self.request.user)
        ).all()
        return form

    def get_context_data(self, **kwargs):
        context = super(NotificationRuleUpdate, self).get_context_data(**kwargs)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        context["device"] = self.device
        context["last_position"] = TraccarPosition.objects.filter(
            device=self.device
        ).first()
        return context

    def get_success_url(self):
        return reverse_lazy(
            "tracking:notificationrule_list",
            kwargs={"device_pk": self.kwargs.get("device_pk")},
        )


class NotificationRuleDelete(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, DeleteView
):
    model = NotificationRule
    template_name = "tracking/notificationrule_confirm_delete.html"
    success_message = _("Notification rule deleted.")

    def get_context_data(self, **kwargs):
        context = super(NotificationRuleDelete, self).get_context_data(**kwargs)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        context["device"] = self.device
        return context

    def get_success_url(self):
        return reverse_lazy(
            "tracking:notificationrule_list",
            kwargs={"device_pk": self.kwargs.get("device_pk")},
        )


# endregion


# region TrackRule


@login_required
@manager_required
def traccartrackrule_create_from_template(request, device_pk):
    device = get_object_or_404(
        TraccarDevice, pk=device_pk, company=get_user_company(request.user)
    )
    if request.method == "POST":
        form = TraccarCreateTrackRuleFromTemplateForm(request.POST, request.FILES)
        if form.is_valid():
            template = form.cleaned_data["template"]
            rule = TraccarTrackRule()
            rule.name = template.name
            rule.description = template.description
            rule.key_search_field = template.key_search_field
            rule.key = template.key
            rule.start_value = template.start_value
            rule.end_value = template.end_value
            rule.color = template.color
            rule.hourly_cost = template.hourly_cost
            rule.distance_cost = template.distance_cost
            rule.device = device
            rule.enabled = True
            rule.save()
            messages.success(request, _("Track rule created successfully."))
            return redirect("tracking:traccartrackrule_list", device_pk=device_pk)
    else:
        form = TraccarCreateTrackRuleFromTemplateForm()
        # form.fields['template'].queryset = TrackRuleTemplate.objects.filter(company=get_user_company(request.user))
    return render(
        request,
        "tracking/traccartrackrule_create_from_template.html",
        {"form": form, "device": device},
    )


class TraccarTrackRuleList(LoginRequiredMixin, ListView):
    template_name = "tracking/traccartrackrule_list.html"
    paginate_by = 10

    def get_queryset(self):
        return TraccarTrackRule.objects.filter(
            device__company=get_user_company(self.request.user),
            device__pk=self.kwargs.get("device_pk"),
        )

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(TraccarTrackRuleList, self).get_context_data(**kwargs)
        context["device"] = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        return context


class TraccarTrackRuleCreate(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, CreateView
):
    model = TraccarTrackRule
    form_class = TraccarTrackRuleForm
    template_name = "tracking/traccartrackrule_form.html"
    success_message = _("Track rule created.")

    def get_context_data(self, **kwargs):
        context = super(TraccarTrackRuleCreate, self).get_context_data(**kwargs)
        context["device"] = self.device
        return context

    def get_form(self, form_class=None):
        form = super(TraccarTrackRuleCreate, self).get_form(form_class)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        return form

    def get_success_url(self):
        return reverse_lazy(
            "tracking:traccartrackrule_list",
            kwargs={"device_pk": self.kwargs.get("device_pk")},
        )

    def form_valid(self, form):
        form.instance.device = self.device
        return super(TraccarTrackRuleCreate, self).form_valid(form)


class TraccarTrackRuleUpdate(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, UpdateView
):
    model = TraccarTrackRule
    form_class = TraccarTrackRuleForm
    template_name = "tracking/traccartrackrule_form.html"
    success_message = _("Track rule updated.")

    def get_context_data(self, **kwargs):
        context = super(TraccarTrackRuleUpdate, self).get_context_data(**kwargs)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        context["device"] = self.device
        return context

    def get_success_url(self):
        return reverse_lazy(
            "tracking:traccartrackrule_list",
            kwargs={"device_pk": self.kwargs.get("device_pk")},
        )


class TraccarTrackRuleDelete(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, DeleteView
):
    model = TraccarTrackRule
    template_name = "tracking/traccartrackrule_confirm_delete.html"
    success_message = _("Track rule deleted.")

    def get_context_data(self, **kwargs):
        context = super(TraccarTrackRuleDelete, self).get_context_data(**kwargs)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        context["device"] = self.device
        return context

    def get_success_url(self):
        return reverse_lazy(
            "tracking:traccartrackrule_list",
            kwargs={"device_pk": self.kwargs.get("device_pk")},
        )


# endregion


# region Chart


@login_required
@manager_required
def chart_create_from_template(request, device_pk):
    device = get_object_or_404(
        TraccarDevice, pk=device_pk, company=get_user_company(request.user)
    )
    if request.method == "POST":
        form = CreateChartFromTemplateForm(request.POST, request.FILES)
        if form.is_valid():
            template = form.cleaned_data["template"]
            chart = Chart()
            chart.name = template.name
            chart.description = template.description
            chart.key = template.key
            chart.key_is_attribute = template.key_is_attribute
            chart.unit = template.unit
            chart.value_ratio = template.value_ratio
            chart.type = template.type
            chart.color = template.color
            chart.device = device
            chart.enabled = True
            chart.save()
            messages.success(request, _("Chart created successfully."))
            return redirect("tracking:chart_list", device_pk=device_pk)
    else:
        form = CreateChartFromTemplateForm()
        # form.fields['template'].queryset = TrackRuleTemplate.objects.filter(company=get_user_company(request.user))
    return render(
        request,
        "tracking/chart_create_from_template.html",
        {"form": form, "device": device},
    )


class ChartList(LoginRequiredMixin, ListView):
    template_name = "tracking/chart_list.html"
    paginate_by = 10

    def get_queryset(self):
        return Chart.objects.filter(
            device__company=get_user_company(self.request.user),
            device__pk=self.kwargs.get("device_pk"),
        )

    def get_context_data(self, *, object_list=None, **kwargs):
        context = super(ChartList, self).get_context_data(**kwargs)
        context["device"] = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        return context


class ChartCreate(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, CreateView
):
    model = Chart
    form_class = ChartForm
    template_name = "tracking/chart_form.html"
    success_message = _("Chart created.")

    def get_context_data(self, **kwargs):
        context = super(ChartCreate, self).get_context_data(**kwargs)
        context["device"] = self.device
        context["last_position"] = TraccarPosition.objects.filter(
            device=self.device
        ).first()
        return context

    def get_form(self, form_class=None):
        form = super(ChartCreate, self).get_form(form_class)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        return form

    def get_success_url(self):
        return reverse_lazy(
            "tracking:chart_list", kwargs={"device_pk": self.kwargs.get("device_pk")}
        )

    def form_valid(self, form):
        form.instance.device = self.device
        return super(ChartCreate, self).form_valid(form)


class ChartUpdate(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, UpdateView
):
    model = Chart
    form_class = ChartForm
    template_name = "tracking/chart_form.html"
    success_message = _("Chart updated.")

    def get_context_data(self, **kwargs):
        context = super(ChartUpdate, self).get_context_data(**kwargs)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        context["device"] = self.device
        context["last_position"] = TraccarPosition.objects.filter(
            device=self.device
        ).first()
        return context

    def get_success_url(self):
        return reverse_lazy(
            "tracking:chart_list", kwargs={"device_pk": self.kwargs.get("device_pk")}
        )


class ChartDelete(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, DeleteView
):
    model = Chart
    template_name = "tracking/chart_confirm_delete.html"
    success_message = _("Chart deleted.")

    def get_context_data(self, **kwargs):
        context = super(ChartDelete, self).get_context_data(**kwargs)
        self.device = get_object_or_404(
            TraccarDevice,
            pk=self.kwargs.get("device_pk"),
            company=get_user_company(self.request.user),
        )
        context["device"] = self.device
        return context

    def get_success_url(self):
        return reverse_lazy(
            "tracking:chart_list", kwargs={"device_pk": self.kwargs.get("device_pk")}
        )


# endregion


# region Region


class RegionList(LoginRequiredMixin, ListView):
    template_name = "tracking/region_list.html"
    paginate_by = 10

    def get_queryset(self):
        return Region.objects.filter(company=get_user_company(self.request.user))


class RegionCreate(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, CreateView
):
    model = Region
    form_class = RegionForm
    template_name = "tracking/region_form.html"
    success_message = _("Region created.")

    def get_success_url(self):
        return reverse_lazy("tracking:region_list")

    def form_valid(self, form):
        company = get_user_company(self.request.user)
        form.instance.company = company
        return super(RegionCreate, self).form_valid(form)


class RegionUpdate(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, UpdateView
):
    model = Region
    form_class = RegionForm
    template_name = "tracking/region_form.html"
    success_message = _("Region updated.")

    def get_success_url(self):
        return reverse_lazy("tracking:region_list")


class RegionDelete(
    LoginRequiredMixin, ManagerRequiredMixin, SuccessMessageMixin, DeleteView
):
    model = Region
    template_name = "tracking/region_confirm_delete.html"
    success_message = _("Region deleted.")

    def get_success_url(self):
        return reverse_lazy("tracking:region_list")


# endregion
