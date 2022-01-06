from github import Github
import sys

### set environment #####################################
print(f"Update file 07-12-2020")
## git access
git_api = "https://github.com/api/v3"
git_key = ""
g = Github(base_url=git_api, login_or_token=git_key)
## git repo
aig_repos = [
"hoangpt2991/test",
"hoangpt2991/test2"
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
    print(f"source branch is {source_branch}")
    print(f"old branch is {old_branch}")
    print(f"new branch is {new_branch}")
    for aig_repo in aig_repos:
        repo = g.get_repo(aig_repo)
        # create new branch from source branch (anz-everest-sprint81 from development)
        branch = repo.get_branch(source_branch)
        try:
            print(f"creating branch {new_branch} on repo {aig_repo}")
            repo.create_git_ref(ref='refs/heads/' + new_branch, sha=branch.commit.sha)
            print(f"created branch {new_branch} on repo {aig_repo}")
        except:
            pass
            print(f"branch {new_branch} is already exist on repo {aig_repo}")
        # add require status check for API/UI
        branch = repo.get_branch(new_branch)
        if aig_repo == "insurance/OmniChannel-Integral-API":
            print(f"configure branch protection for branch {new_branch} on repo {aig_repo}")
            branch.edit_protection(strict=True,enforce_admins=True)
            #branch.edit_required_status_checks(strict=True,contexts=status_check_api)
        if aig_repo == "insurance/Omnichanel-Integral-UI-AIG":
            print(f"configure branch protection for branch {new_branch} on repo {aig_repo}")
            branch.edit_protection(strict=True,enforce_admins=True)
            #branch.edit_required_status_checks(strict=True,contexts=status_check_ui)
        # freeze old branch (eg. anz-everest-sprint80)        
        try:
            branch = repo.get_branch(old_branch)       
            print(f"configure branch protection for branch {old_branch} on repo {aig_repo}")
            branch.edit_protection(strict=True,enforce_admins=True,user_push_restrictions=user_push)
            #branch.remove_required_status_checks()
        except:
            pass
            print(f"branch {old_branch} is not exist on repo {aig_repo}")

GitNewSprint()