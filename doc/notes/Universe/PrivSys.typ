
#import "/lib/typst-mode/lib/_lib.typ/lib.typ": meta, mkheading
#import "../aut.typ": mujiu

#meta(
  title: [Security Subsystem:],
  date: datetime(year: 2025, month: 12, day: 14, hour: 23, minute: 46, second: 0),
  authors: (mujiu,),
  id: "dflat-privSys",
  parent_id: "index",
)

#mkheading()

== Privilege Fields

1. READ: Readable, Can fetch contents
2. WRITE: Writable, Can create file, can append file, can overwrite file
3. MODIFY: Modifiable, Can request operation on server side files, without download and upload file
4. DELETE: Removable, Can delete a file
5. ACCESS: Accessible, Can query a list, Can read metadata

== STATUS Enumerators

1. AVAILABLE: The entity is currently available
2. BANNED: The entity is temporary unavailable
3. REMOVED: The entity is removed permanently
4. PENDING: The entity is waiting for permission

== GROUP

1. ID:          UUID v7
2. NAME:        STR
3. DESCRIPTION: STR
4. ENABLED:     BOOL
5. SYSTEM:      BOOL

6. CREATE_AT:   TIME
7. UPDATE_AT:   TIME
9. STATUS:      STATUS

== USER

1. ID:          INT
2. NICK_NAME:   STR
3. REAL_NAME:   STR

4. PASSWD:      STR
5. PHONE:       STR
6. MAIL:        STR

7. VALIDATING:  BOOL
8. ENABLED:     BOOL
9. LOCKED:      BOOL:       If locked, the account cannot be used
10. IS_SYSTEM:  BOOL:       If is system, the account is created by the scripts auto
11. FROZEN:     BOOL:       If frozen, the account is not modifiable

12. PASSWD_UPDATE_AT: TIME
13. PASSWD_EXPIRED_AT: TIME
14. ACCOUNT_CREATE_AT: TIME
15. ACCOUNT_EXPIRED_AT: TIME

16. LAST_LOGIN_AT: TIME

17. CREATE_AT:  TIME
18. UPDATE_AT:  TIME
19. STATUS:     STATUS

== SCHOOL

1. ID:          UUID v7
2. NAME:        STR

17. CREATE_AT:  TIME
18. UPDATE_AT:  TIME
19. STATUS:     STATUS

== RTYPE Enumerators

1. ABSTRACT
2. API
3. FILE

== RESOURCE

1. ID:          UUID v7
2. NAME:        STR
3. RTYPE:       RTYPE
4. URI:         STR
5. OWNER:       USER ID fk

6. CREATE_AT:   TIME
7. UPDATE_AT:   TIME
8. STATUS:      STATUS

9. DPROTECTION: BOOL

== USER RESOURCE ACL

1. ID:          UUID v7
2. RESOURCE:    RESOURCE ID fk
3. USER:        USER ID fk

4. READ:        BOOL
5. WRITE:       BOOL
6. MODIFY:      BOOL
7. DELETE:      BOOL
8. ACCESS:      BOOL

9. GRANTED_BY:  USER ID fk
10. VALID_FROM: TIME
11. VALID_UNTIL:TIME

12. CREATE_AT:  TIME
13. UPDATE_AT:  TIME
14. STATUS:     STATUS

== GROUP RESOURCE ACL

1. ID:          UUID v7
2. RESOURCE:    RESOURCE ID fk
3. GROUP:       GROUP ID fk

4. READ:        BOOL
5. WRITE:       BOOL
6. MODIFY:      BOOL
7. DELETE:      BOOL
8. ACCESS:      BOOL

9. GRANTED_BY:  USER ID fk
10. VALID_FROM: TIME
11. VALID_UNTIL:TIME

12. CREATE_AT:  TIME
13. UPDATE_AT:  TIME
14. STATUS:     STATUS

== RACTION Enumerators

1. READ
2. WRITE
3. MODIFY
4. DELETE
5. ACCESS

== RESOURCE AUDIT LOG

8. table resource_audit_log: id(v7 uuid, pk), resource_id(fk), user_id(user requesting, fk), action(read, write, modify, delete, access), result(success, failed), details(text), attempt_time, created_at, updated_at

1. ID:          UUID v7
2. RESOURCE:    RESOURCE ID fk: The resource being requested
3. USER:        USER ID fk: The user requesting
4. RACTION:     RACTION
5. DETAILS:     STR
6. ATTEMPT_TIME:TIME

7. CREATE_AT:   TIME
8. UPDATE_AT:   TIME
9. STATUS:      STATUS

== USER GROUP MEMBERS

15. define user_group_members table: id(v7 uuid), user_id(fk), group_id(fk), joined_at, created_at, updated_at, assigned_by

1. ID:          UUID v7
2. USER:        USER ID fk
3. GROUP:       GROUP ID fk
4. ASSIGNED_BY: USER ID fk

5. CREATE_AT:   TIME
6. UPDATE_AT:   TIME
7. STATUS:      STATUS

== UMASK

1. ID:          UUID v7
2. USER:        USER ID fk
3. MIME_TYPE:   STR
4. PRIV:        INT

5. OWNER_READ:  BOOL
6. OWNER_WRITE: BOOL
7. OWNER_MODIFY:BOOL
8. OWNER_DELETE:BOOL
9. OWNER_ACCESS:BOOL

10. OTHER_READ: BOOL
11. OTHER_WRITE:BOOL
12. OTHER_MODIFY:BOOL
13. OTHER_DELETE:BOOL
14. OTHER_ACCESS:BOOL

15. CREATE_AT:  TIME
16. UPDATE_AT:  TIME
17. STATUS:     STATUS

== PRIV Calc

1. find user_resource_acl, if user's priv is defined, accept if true, decline if false and break the process;
2. then find group_resource_acl, if user belongs to the groups in group_resource_acl, merge all priv defined in the gacl (or opt) and break the process;
3. if neither uacl nor gacl defines the priv of that user,
  - the user is not the owner as well, find the file owner's umask for this kind of file, use other's priv;
  - if the user is the owner of that file, find the file owner's umake for this kind of file, user owner's priv;
  and break the process;
4. by default, the user do not have any priv to this file

== APIs

