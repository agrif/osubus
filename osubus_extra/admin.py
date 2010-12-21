from osubus_extra.models import ExternalLink, Screenshot
from django.contrib import admin

class ExternalLinkAdmin(admin.ModelAdmin):
    list_display = ('name', 'url')

class ScreenshotAdmin(admin.ModelAdmin):
    list_display = ('title', 'image')

admin.site.register(ExternalLink, ExternalLinkAdmin)
admin.site.register(Screenshot, ScreenshotAdmin)

