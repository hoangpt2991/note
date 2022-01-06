from __future__ import print_function
from github import Github
import sys

###version python 3.5.2
### set environment #####################################

## git access
git_api = "https://github.com/api/v3"
git_key = "a2012453bb41dc5b48586a717ed541f70e3b77c7"
g = Github(base_url=git_api, login_or_token=git_key)
## git repo
individual_repos = [
   apache_cmd
]
source_branch = sys.argv[1]
old_branch = sys.argv[2]
new_branch = sys.argv[3]

## branch configure
user_push = ["no_body"]
status_check_api = ["EV-SWAT-API2-PREBUILD"]
status_check_ui = ["TEAM-UIAIG-PREBUILD"]

########################################################

def GitNewSprint():
    print("source branch is {source_branch}")
    print("old branch is {old_branch}")
    print("new branch is {new_branch}")
    for aig_repo in aig_repos:
        repo = g.get_repo(aig_repo)
        # create new branch from source branch (anz-everest-sprint81 from development)
        branch = repo.get_branch(source_branch)
        try:
            print("creating branch {new_branch} on repo {aig_repo}")
            repo.create_git_ref(ref='refs/heads/' + new_branch, sha=branch.commit.sha)
            print("created branch {new_branch} on repo {aig_repo}")
        except:
            pass
            print("branch {new_branch} is already exist on repo {aig_repo}")
        # add require status check for API/UI
        branch = repo.get_branch(new_branch)
        if aig_repo == "insurance/OmniChannel-Integral-API":
            print("configure branch protection for branch {new_branch} on repo {aig_repo}")
            branch.edit_protection(strict=True,enforce_admins=True)
            branch.edit_required_status_checks(strict=True,contexts=status_check_api)
        if aig_repo == "insurance/Omnichanel-Integral-UI-AIG":
            print("configure branch protection for branch {new_branch} on repo {aig_repo}")
            branch.edit_protection(strict=True,enforce_admins=True)
            branch.edit_required_status_checks(strict=True,contexts=status_check_ui)
        # freeze old branch (eg. anz-everest-sprint80)        
        try:
            branch = repo.get_branch(old_branch)       
            print("configure branch protection for branch {old_branch} on repo {aig_repo}")
            branch.edit_protection(strict=True,enforce_admins=True,user_push_restrictions=user_push)
            branch.remove_required_status_checks()
        except:
            pass
            print("branch {old_branch} is not exist on repo {aig_repo}")

GitNewSprint()
