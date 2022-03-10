
Form groups from previously defined lists
Groups must have 3 elements and can only be formed inside each list

March 2022, J. Gaspar

-------------------------------------------------------------------

Student defining the group, just run:
>> groups_manage('mygroup')

Note: This command will fail (abort) after three input errors. So you can press RET 3x to abort your input.


Student or Professor, to see the formed groups:
>> groups_manage('show')


Issue, duplication of registrations. Professor:
groups_manage('needs_cleanup')
groups_manage('add_clean')
groups_manage('save')
