from django.conf.urls import *

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = [
    # Example:
    # url(r'^osubus_web/', include('osubus_web.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
]

import osubus_extra.views

urlpatterns += [
    url(r'^screenshots$', osubus_extra.views.screenshots),
    url(r'^statistics$', osubus_extra.views.stats),
    url(r'^api/(?P<api_version>v\d+)/getservicebulletins', osubus_extra.views.bulletins),
]
