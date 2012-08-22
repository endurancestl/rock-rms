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
using System;

using Rock.Data;

namespace Rock.Groups
{
	/// <summary>
	/// Data Transfer Object for Group object
	/// </summary>
	public partial class GroupDTO : DTO<Group>
	{

#pragma warning disable 1591
		public bool IsSystem { get; set; }
		public int? ParentGroupId { get; set; }
		public int GroupTypeId { get; set; }
		public string Name { get; set; }
		public string Description { get; set; }
		public bool IsSecurityRole { get; set; }
#pragma warning restore 1591

		/// <summary>
		/// Instantiates a new DTO object
		/// </summary>
		public GroupDTO ()
		{
		}

		/// <summary>
		/// Instantiates a new DTO object from the model
		/// </summary>
		/// <param name="group"></param>
		public GroupDTO ( Group group )
		{
			CopyFromModel( group );
		}

		/// <summary>
		/// Copies the model property values to the DTO properties
		/// </summary>
		/// <param name="group"></param>
		public override void CopyFromModel( Group group )
		{
			this.IsSystem = group.IsSystem;
			this.ParentGroupId = group.ParentGroupId;
			this.GroupTypeId = group.GroupTypeId;
			this.Name = group.Name;
			this.Description = group.Description;
			this.IsSecurityRole = group.IsSecurityRole;
			this.CreatedDateTime = group.CreatedDateTime;
			this.ModifiedDateTime = group.ModifiedDateTime;
			this.CreatedByPersonId = group.CreatedByPersonId;
			this.ModifiedByPersonId = group.ModifiedByPersonId;
			this.Id = group.Id;
			this.Guid = group.Guid;
		}

		/// <summary>
		/// Copies the DTO property values to the model properties
		/// </summary>
		/// <param name="group"></param>
		public override void CopyToModel ( Group group )
		{
			group.IsSystem = this.IsSystem;
			group.ParentGroupId = this.ParentGroupId;
			group.GroupTypeId = this.GroupTypeId;
			group.Name = this.Name;
			group.Description = this.Description;
			group.IsSecurityRole = this.IsSecurityRole;
			group.CreatedDateTime = this.CreatedDateTime;
			group.ModifiedDateTime = this.ModifiedDateTime;
			group.CreatedByPersonId = this.CreatedByPersonId;
			group.ModifiedByPersonId = this.ModifiedByPersonId;
			group.Id = this.Id;
			group.Guid = this.Guid;
		}
	}
}
