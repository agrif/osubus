from django.db import models

class ExternalLink(models.Model):
    name = models.CharField(max_length=200)
    url = models.URLField()
    
    def __unicode__(self):
        return self.name

