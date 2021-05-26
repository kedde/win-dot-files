Import-Module posh-git
function ga {
	git add $args
}
function gaa {
	git add --all
}
function gb {
	git branch
}
function gcb {
	git checkout -b
}
function gcm {
	git checkout master
}
function gcmsg {
	git commit -m $args
}
function gco {
	git checkout $args
}
function gd {
	git diff $args
}
function gdca {
	git diff --cached
}
function gf {
	git fetch $args
}
function gfa {
	git fetch --all --prune
}
function gfo {
	git fetch origin
}
function ggpull {
    $branch= &git rev-parse --abbrev-ref HEAD 
	git pull origin $branch
}
function ggpush {
    $branch= &git rev-parse --abbrev-ref HEAD 
	git push origin $branch
}
function gm {
	git merge $args
}
function gmom {
	git merge origin/master
}
function gp {
	git push $args
}
function grh {
	git reset HEAD
}
function grhh {
	git reset HEAD --hard
}
function grv {
	git remote -v
}
function gss {
	git status -s
}

#go to branch
function gb($pattern){
    while($pattern -eq $null -or $pattern -eq ""){
        write-host "please give a sub string in the branch name, here are the branches:" -f red
        git branch

        $pattern = Read-Host "Switch to: "
    }
    
    $branches = git branch | ?{$_ -like "*$pattern*"}
    if($branches.count -gt 1){
        write-host "matches $($branches.count) :" -f green
        write-host "==================================="
        0..($branches.count-1) | %{write-host "$_ : $($branches[$_])"}
        write-host "==================================="
        $index = Read-Host "Please select the index: "

        $branch = $branches[$index]
        git co $branch.trim("*").trim()
    }
    elseif ($branches.count -eq 1){
        $branch = $branches | Select-Object -first 1
        git co $branch.trim("*").trim()
    }
}


# clean local branch that deleted remotely
function git-clean{
    $currentBranch = git symbolic-ref --short HEAD
    $currentBranch = $currentBranch.Trim()
    git remote prune origin
    $branches = git branch --merged | ?{!($_ -like "*master*" -or $_ -like "*develop*" -or $_ -like "*$currentBranch*")}

    if($branches.count -gt 0){
        write-host "Clean branches: "
        $branches | %{ write-host $_ -f yellow}
        $branches.trim() | %{ git branch -d $_ } 
    }
}

# set upstream for new created local branch
function gitup(){
    # git push --set-upstream origin feature/abc

    $currentBranch = git symbolic-ref --short HEAD
    $currentBranch = $currentBranch.trim()
    write-host "Current branch: <$currentBranch>" -f green

    git push --set-upstream origin $currentBranch
}

function showBranchCommit(){
	$currentBranch = git symbolic-ref --short HEAD
	git log --no-merges --graph --oneline --decorate develop..$currentBranch
}