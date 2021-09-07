import copy
from unittest import skipIf

from django.test import TestCase

from dolt.models import Branch
from dolt.constants import DOLT_DEFAULT_BRANCH


class TestBranches(TestCase):
    def test_default_branch(self):
        self.assertEqual(Branch.objects.filter(name=DOLT_DEFAULT_BRANCH).count(), 1)

    def test_create_branch(self):
        Branch(name="other", starting_branch=DOLT_DEFAULT_BRANCH).save()
        self.assertEqual(Branch.objects.all().count(), 2)
