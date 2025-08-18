Git Flow
========

## Summary

The Git Flow branch module is a convention concentrate on the structure of git repositories, which has been provided by Vincent Driessen initial in 2010. It provide a way to control the work flow together with git; which make it more effective to develop, to test and to publish a product.

Here we define a standard structure of branches in this repository.

The branch name should be structured as follows:
```
<user>@<branch-type>[/<branch-info>]
```

The branch name contains the following structural elements:
1. `master`: keep stable and publishable. Every time there is about to release a new distribution, merge branch from develop to master.
2. `dev`/`develop`: Merge all branch for develop purpose.
3. `feat`/`feature`: Develop new feature. Create from `develop`, and merged into `develop` after finishing all job and ensuring bug-free. Naming convention:
```
feature/<feature-name>
```
or
```
feat/<feature-name>
```
4. `release`: Prepare for new release. Merged back into `develop` and `master` after passing all test cases and making release tag. Naming convention:
```
release/<release-name>
```
5. `hotfix`: Fix for emergency bug. Create from `master`, and merge back into `develop` and `master` after finishing all work and making tag. Naming convention:
```
hotfox/<bug-id>
```
6. `fix`: Fix for regular bug. Create from `develop` and merged back to `develop`.

## Example

## Specification

## Appendix
