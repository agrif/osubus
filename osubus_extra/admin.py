from osubus_extra.models import ExternalLink
from django.contrib import admin

class ExternalLinkAdmin(admin.ModelAdmin):
    list_display = ('name', 'url')

admin.site.register(ExternalLink, ExternalLinkAdmin)

