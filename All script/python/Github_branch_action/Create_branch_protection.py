import os
from github import Github
import sys

#choose_repo = 'gitapi'
choose_account = 'hoangpt2991'
#choose_sprint = 'sprint1'
# or using an access token
g = Github("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")

list_repositories = [
  "test2"
  ]
print(list_repositories)

#repo_name = choose_account + "/" + choose_repo
#branch  = g.get_repo(repo_name).get_branch(choose_sprint)
#print("Branh protected: ",branch.protected)


####################################
# CREATE NEW BRANCH           ###### 
####################################
#target_branch = 'newfeature'

#input repo wanna create new branch
#repo = g.get_user().get_repo(choose_repo)

#source branch input
#sb = repo.get_branch(choose_sprint)

#repo.create_git_ref(ref='refs/heads/' + target_branch, sha=sb.commit.sha)

#### create target branch from source branch, freeze old branch 
def create_target_branch():
  global list_repositories,choose_account
  input_source_branch = sys.argv[1]
  input_target_branch = sys.argv[2]
  #input_source_branch="branch-15"
  #input_target_branch="branch-16"
  print('Account is working is: ',choose_account)
  print('This is source branch: ',input_source_branch)
  print('This is target branch: ',input_target_branch)

  
  #start loop action one by one repository: add new branch, create tag
  for repository in list_repositories:
   repo_name = choose_account + "/" + repository
   branch  = g.get_repo(repo_name).get_branch(input_source_branch)
   repo = g.get_user().get_repo(repository)
   sb = repo.get_branch(input_source_branch) 
   try:
     #create new branch
     print("Create target branch [{}] from source branch [{}] on repository [{}]".format(input_target_branch,input_source_branch,repository))
     repo.create_git_ref(ref='refs/heads/' + input_target_branch, sha=sb.commit.sha)
     
     #create tag
     #t = repo.create_git_tag(tag='input_source_branch',message='script',object=sha,type='commit')
     #repo.create_git_tag_and_release(tag='input_source_branch', tag_message='none', release_name='none', release_message='none', object='sha', type='commit', tagger=NotSet, draft=False, prerelease=False)
     #repo.create_git_ref('refs/tags/{}'.format(t.tag), t.sha)
     #repo.create_git_release(tag='input_source_branch', name='', message='', draft=False, prerelease=False, target_commitish=NotSet)
   except:
     pass
     #print(f"The branch {input_target_branch} is already exist on repository {repository}")
     print("The branch {} is already exist on repository {}".format(input_target_branch,repository))
   try:
     
     print("Configure branch protection for branch {} on repo {}".format(input_source_branch,repository))

     
     branch.edit_protection(strict=True, enforce_admins=True)
     print('This branch is protected?', branch.protected)
     print("Completed to create protection rule for {} branch".format(input_source_branch))
   except:
     pass
     print("Branch {} freeze unsucceed on {}".format(input_source_branch,repository))
     
if __name__ == "__main__":
   create_target_branch()
   
#edit_protection(strict=NotSet, contexts=NotSet, enforce_admins=NotSet, dismissal_users=NotSet, dismissal_teams=NotSet,
#dismiss_stale_reviews=NotSet, require_code_owner_reviews=NotSet, required_approving_review_count=NotSet, user_push_restrictions=NotSet, team_push_restrictions=NotSet)
