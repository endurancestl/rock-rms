//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by the Rock.CodeGeneration project
//     Changes to this file will be lost when the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
//
// THIS WORK IS LICENSED UNDER A CREATIVE COMMONS ATTRIBUTION-NONCOMMERCIAL-
// SHAREALIKE 3.0 UNPORTED LICENSE:
// http://creativecommons.org/licenses/by-nc-sa/3.0/
//

using Rock.Groups;

namespace Rock.Rest.Groups
{
	/// <summary>
	/// Groups REST API
	/// </summary>
	public partial class GroupsController : Rock.Rest.ApiController<Rock.Groups.Group, Rock.Groups.GroupDTO>
	{
		public GroupsController() : base( new Rock.Groups.GroupService() ) { } 
	}
}
