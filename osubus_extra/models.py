from django.db import models

class ExternalLink(models.Model):
    name = models.CharField(max_length=200)
    url = models.URLField()
    
    def __unicode__(self):
        return self.name

class Screenshot(models.Model):
    image = models.ImageField(upload_to="screenshots/")
    title = models.CharField(max_length=200)
    description = models.TextField(max_length=1024)
    
    def __unicode__(self):
        return self.title

PRIORITY_CHOICES = (
    (0, 'Low'),
    (1, 'Medium'),
    (2, 'High'),
)

class MetaBulletin(models.Model):
    title = models.CharField(max_length=200)
    priority = models.PositiveSmallIntegerField(choices=PRIORITY_CHOICES, default=0)
    body = models.TextField(max_length=8192)
    
    def __unicode__(self):
        return self.title
    
    class Meta:
        abstract = True

class Bulletin(MetaBulletin):
    pass

class VersionBulletin(MetaBulletin):
    major = models.PositiveSmallIntegerField()
    minor = models.PositiveSmallIntegerField()
    revision = models.PositiveSmallIntegerField()
    
    def __unicode__(self):
        return str(self.major) + '.' + str(self.minor) + '.' + str(self.revision)
    
    class Meta(MetaBulletin.Meta):
        unique_together = (('major', 'minor', 'revision'),)
        ordering = ['-major', '-minor', '-revision']
