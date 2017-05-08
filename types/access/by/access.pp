# @since 2.0.0
type OpenLDAP::Access::By::Access = Pattern[/(?x) ^ (?: (?: real )? self )? (?: none | disclose | auth | compare | search | read |  write | add | delete | manage | [-+=] [0dxcsrwazm]+ ) $/]
