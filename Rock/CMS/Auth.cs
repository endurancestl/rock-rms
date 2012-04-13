//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by the T4\Model.tt template.
//
//     Changes to this file will be lost when the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------
//
// THIS WORK IS LICENSED UNDER A CREATIVE COMMONS ATTRIBUTION-NONCOMMERCIAL-
// SHAREALIKE 3.0 UNPORTED LICENSE:
// http://creativecommons.org/licenses/by-nc-sa/3.0/
//
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Data.Entity.ModelConfiguration;
using System.Runtime.Serialization;

using Rock.Data;

namespace Rock.CMS
{
    /// <summary>
    /// Auth POCO Entity.
    /// </summary>
    [Table( "cmsAuth" )]
    public partial class Auth : ModelWithAttributes<Auth>, IAuditable, IOrdered
    {
		/// <summary>
		/// Gets or sets the Entity Type.
		/// </summary>
		/// <value>
		/// Entity Type.
		/// </value>
		[MaxLength( 200 )]
		[DataMember]
		public string EntityType { get; set; }
		
		/// <summary>
		/// Gets or sets the Entity Id.
		/// </summary>
		/// <value>
		/// Entity Id.
		/// </value>
		[DataMember]
		public int? EntityId { get; set; }
		
		/// <summary>
		/// Gets or sets the Order.
		/// </summary>
		/// <value>
		/// Order.
		/// </value>
		[DataMember]
		public int Order { get; set; }
		
		/// <summary>
		/// Gets or sets the Allow Or Deny.
		/// </summary>
		/// <value>
		/// A = Allow, D = Deny.
		/// </value>
		[DataMember]
		public string AllowOrDeny { get; set; }
		
		/// <summary>
		/// Gets or sets the User Or Role.
		/// </summary>
		/// <value>
		/// U = User, R = Role.
		/// </value>
		[DataMember]
		public string UserOrRole { get; set; }
		
		/// <summary>
		/// Gets or sets the Action.
		/// </summary>
		/// <value>
		/// Action.
		/// </value>
		[MaxLength( 50 )]
		[DataMember]
		public string Action { get; set; }
		
		/// <summary>
		/// Gets or sets the User Or Role Name.
		/// </summary>
		/// <value>
		/// User Or Role Name.
		/// </value>
		[MaxLength( 100 )]
		[DataMember]
		public string UserOrRoleName { get; set; }
		
		/// <summary>
		/// Gets or sets the Created Date Time.
		/// </summary>
		/// <value>
		/// Created Date Time.
		/// </value>
		[DataMember]
		public DateTime? CreatedDateTime { get; set; }
		
		/// <summary>
		/// Gets or sets the Modified Date Time.
		/// </summary>
		/// <value>
		/// Modified Date Time.
		/// </value>
		[DataMember]
		public DateTime? ModifiedDateTime { get; set; }
		
		/// <summary>
		/// Gets or sets the Created By Person Id.
		/// </summary>
		/// <value>
		/// Created By Person Id.
		/// </value>
		[DataMember]
		public int? CreatedByPersonId { get; set; }
		
		/// <summary>
		/// Gets or sets the Modified By Person Id.
		/// </summary>
		/// <value>
		/// Modified By Person Id.
		/// </value>
		[DataMember]
		public int? ModifiedByPersonId { get; set; }
		
		/// <summary>
        /// Gets a Data Transfer Object (lightweight) version of this object.
        /// </summary>
        /// <value>
        /// A <see cref="Rock.CMS.DTO.Auth"/> object.
        /// </value>
		public Rock.CMS.DTO.Auth DataTransferObject
		{
			get 
			{ 
				Rock.CMS.DTO.Auth dto = new Rock.CMS.DTO.Auth();
				dto.Id = this.Id;
				dto.Guid = this.Guid;
				dto.EntityType = this.EntityType;
				dto.EntityId = this.EntityId;
				dto.Order = this.Order;
				dto.AllowOrDeny = this.AllowOrDeny;
				dto.UserOrRole = this.UserOrRole;
				dto.Action = this.Action;
				dto.UserOrRoleName = this.UserOrRoleName;
				dto.CreatedDateTime = this.CreatedDateTime;
				dto.ModifiedDateTime = this.ModifiedDateTime;
				dto.CreatedByPersonId = this.CreatedByPersonId;
				dto.ModifiedByPersonId = this.ModifiedByPersonId;
				return dto; 
			}
		}

        /// <summary>
        /// Gets the auth entity.
        /// </summary>
		[NotMapped]
		public override string AuthEntity { get { return "CMS.Auth"; } }
        
		/// <summary>
        /// Gets or sets the Created By Person.
        /// </summary>
        /// <value>
        /// A <see cref="CRM.Person"/> object.
        /// </value>
		public virtual CRM.Person CreatedByPerson { get; set; }
        
		/// <summary>
        /// Gets or sets the Modified By Person.
        /// </summary>
        /// <value>
        /// A <see cref="CRM.Person"/> object.
        /// </value>
		public virtual CRM.Person ModifiedByPerson { get; set; }

    }
    /// <summary>
    /// Auth Configuration class.
    /// </summary>
    public partial class AuthConfiguration : EntityTypeConfiguration<Auth>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="AuthConfiguration"/> class.
        /// </summary>
        public AuthConfiguration()
        {
			this.HasOptional( p => p.CreatedByPerson ).WithMany().HasForeignKey( p => p.CreatedByPersonId ).WillCascadeOnDelete(false);
			this.HasOptional( p => p.ModifiedByPerson ).WithMany().HasForeignKey( p => p.ModifiedByPersonId ).WillCascadeOnDelete(false);
		}
    }
}
