from osubus_extra.models import ExternalLink, Screenshot, Bulletin, VersionBulletin, CacheDatabase, VersionStats
from django import forms
from django.contrib import admin

class ExternalLinkAdmin(admin.ModelAdmin):
    list_display = ('name', 'url')

class ScreenshotAdmin(admin.ModelAdmin):
    list_display = ('title', 'image')

class BulletinAdmin(admin.ModelAdmin):
    list_display = ('title', 'priority')

class VersionBulletinModelForm(forms.ModelForm):
    class Meta:
        model = VersionBulletin
        fields = ('version', 'title', 'priority', 'body')
    
    def __init__(self, *args, **kwargs):
        if 'instance' in kwargs.keys():
            if not 'initial' in kwargs.keys():
                kwargs['initial'] = {}
            
            kwargs['initial']['version'] = str(kwargs['instance'])
        super(VersionBulletinModelForm, self).__init__(*args, **kwargs)
    
    version = forms.CharField(max_length=64)
    def clean_version(self):
        version = self.cleaned_data['version']
        try:
            version = map(int, version.split('.', 2))
            if not len(version) == 3:
                raise ValueError
        except ValueError:
            raise forms.ValidationError("invalid version string (form #.#.#)")
        return self.cleaned_data['version']
    
    def save(self, force_insert=False, force_update=False, commit=True):
        m = super(VersionBulletinModelForm, self).save(commit=False)
        
        versions = map(int, self.cleaned_data['version'].split('.', 2))
        m.major = versions[0]
        m.minor = versions[1]
        m.revision = versions[2]
        
        m.full_clean()
        
        if commit:
            m.save()
        return m

class VersionBulletinAdmin(admin.ModelAdmin):
    form = VersionBulletinModelForm        
    list_display = ('__unicode__', 'title')

class CacheDatabaseAdmin(admin.ModelAdmin):
    list_display = ('__unicode__', 'version', 'date', 'file')

class VersionStatsAdmin(admin.ModelAdmin):
    list_display = ('__unicode__', 'count', 'dbversion', 'dbdate')

admin.site.register(ExternalLink, ExternalLinkAdmin)
admin.site.register(Screenshot, ScreenshotAdmin)
admin.site.register(Bulletin, BulletinAdmin)
admin.site.register(VersionBulletin, VersionBulletinAdmin)
admin.site.register(CacheDatabase, CacheDatabaseAdmin)
admin.site.register(VersionStats, VersionStatsAdmin)
