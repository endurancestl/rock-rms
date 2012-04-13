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
    /// Blog Post Comment POCO Entity.
    /// </summary>
    [Table( "cmsBlogPostComment" )]
    public partial class BlogPostComment : ModelWithAttributes<BlogPostComment>, IAuditable
    {
		/// <summary>
		/// Gets or sets the Post Id.
		/// </summary>
		/// <value>
		/// Post Id.
		/// </value>
		[DataMember]
		public int PostId { get; set; }
		
		/// <summary>
		/// Gets or sets the Person Id.
		/// </summary>
		/// <value>
		/// Person Id.
		/// </value>
		[DataMember]
		public int? PersonId { get; set; }
		
		/// <summary>
		/// Gets or sets the Person Name.
		/// </summary>
		/// <value>
		/// Person Name.
		/// </value>
		[MaxLength( 250 )]
		[DataMember]
		public string PersonName { get; set; }
		
		/// <summary>
		/// Gets or sets the Comment Date.
		/// </summary>
		/// <value>
		/// Comment Date.
		/// </value>
		[DataMember]
		public DateTime? CommentDate { get; set; }
		
		/// <summary>
		/// Gets or sets the Email Address.
		/// </summary>
		/// <value>
		/// Email Address.
		/// </value>
		[MaxLength( 150 )]
		[DataMember]
		public string EmailAddress { get; set; }
		
		/// <summary>
		/// Gets or sets the Comment.
		/// </summary>
		/// <value>
		/// Comment.
		/// </value>
		[DataMember]
		public string Comment { get; set; }
		
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
        /// A <see cref="Rock.CMS.DTO.BlogPostComment"/> object.
        /// </value>
		public Rock.CMS.DTO.BlogPostComment DataTransferObject
		{
			get 
			{ 
				Rock.CMS.DTO.BlogPostComment dto = new Rock.CMS.DTO.BlogPostComment();
				dto.Id = this.Id;
				dto.Guid = this.Guid;
				dto.PostId = this.PostId;
				dto.PersonId = this.PersonId;
				dto.PersonName = this.PersonName;
				dto.CommentDate = this.CommentDate;
				dto.EmailAddress = this.EmailAddress;
				dto.Comment = this.Comment;
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
		public override string AuthEntity { get { return "CMS.BlogPostComment"; } }
        
		/// <summary>
        /// Gets or sets the Post.
        /// </summary>
        /// <value>
        /// A <see cref="BlogPost"/> object.
        /// </value>
		public virtual BlogPost Post { get; set; }
        
		/// <summary>
        /// Gets or sets the Person.
        /// </summary>
        /// <value>
        /// A <see cref="CRM.Person"/> object.
        /// </value>
		public virtual CRM.Person Person { get; set; }
        
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
    /// Blog Post Comment Configuration class.
    /// </summary>
    public partial class BlogPostCommentConfiguration : EntityTypeConfiguration<BlogPostComment>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="BlogPostCommentConfiguration"/> class.
        /// </summary>
        public BlogPostCommentConfiguration()
        {
			this.HasRequired( p => p.Post ).WithMany( p => p.BlogPostComments ).HasForeignKey( p => p.PostId ).WillCascadeOnDelete(true);
			this.HasOptional( p => p.Person ).WithMany( p => p.BlogPostComments ).HasForeignKey( p => p.PersonId ).WillCascadeOnDelete(false);
			this.HasOptional( p => p.CreatedByPerson ).WithMany().HasForeignKey( p => p.CreatedByPersonId ).WillCascadeOnDelete(false);
			this.HasOptional( p => p.ModifiedByPerson ).WithMany().HasForeignKey( p => p.ModifiedByPersonId ).WillCascadeOnDelete(false);
		}
    }
}
