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

namespace Rock.CMS
{
	/// <summary>
	/// Data Transfer Object for User object
	/// </summary>
	public partial class UserDTO : DTO<User>
	{

#pragma warning disable 1591
		public string UserName { get; set; }
		public AuthenticationType AuthenticationType { get; set; }
		public string Password { get; set; }
		public bool? IsConfirmed { get; set; }
		public DateTime? LastActivityDate { get; set; }
		public DateTime? LastLoginDate { get; set; }
		public DateTime? LastPasswordChangedDate { get; set; }
		public DateTime? CreationDate { get; set; }
		public bool? IsOnLine { get; set; }
		public bool? IsLockedOut { get; set; }
		public DateTime? LastLockedOutDate { get; set; }
		public int? FailedPasswordAttemptCount { get; set; }
		public DateTime? FailedPasswordAttemptWindowStart { get; set; }
		public string ApiKey { get; set; }
		public int? PersonId { get; set; }
#pragma warning restore 1591

		/// <summary>
		/// Instantiates a new DTO object
		/// </summary>
		public UserDTO ()
		{
		}

		/// <summary>
		/// Instantiates a new DTO object from the model
		/// </summary>
		/// <param name="user"></param>
		public UserDTO ( User user )
		{
			CopyFromModel( user );
		}

		/// <summary>
		/// Copies the model property values to the DTO properties
		/// </summary>
		/// <param name="user"></param>
		public override void CopyFromModel( User user )
		{
			this.UserName = user.UserName;
			this.AuthenticationType = user.AuthenticationType;
			this.Password = user.Password;
			this.IsConfirmed = user.IsConfirmed;
			this.LastActivityDate = user.LastActivityDate;
			this.LastLoginDate = user.LastLoginDate;
			this.LastPasswordChangedDate = user.LastPasswordChangedDate;
			this.CreationDate = user.CreationDate;
			this.IsOnLine = user.IsOnLine;
			this.IsLockedOut = user.IsLockedOut;
			this.LastLockedOutDate = user.LastLockedOutDate;
			this.FailedPasswordAttemptCount = user.FailedPasswordAttemptCount;
			this.FailedPasswordAttemptWindowStart = user.FailedPasswordAttemptWindowStart;
			this.ApiKey = user.ApiKey;
			this.PersonId = user.PersonId;
			this.CreatedDateTime = user.CreatedDateTime;
			this.ModifiedDateTime = user.ModifiedDateTime;
			this.CreatedByPersonId = user.CreatedByPersonId;
			this.ModifiedByPersonId = user.ModifiedByPersonId;
			this.Id = user.Id;
			this.Guid = user.Guid;
		}

		/// <summary>
		/// Copies the DTO property values to the model properties
		/// </summary>
		/// <param name="user"></param>
		public override void CopyToModel ( User user )
		{
			user.UserName = this.UserName;
			user.AuthenticationType = this.AuthenticationType;
			user.Password = this.Password;
			user.IsConfirmed = this.IsConfirmed;
			user.LastActivityDate = this.LastActivityDate;
			user.LastLoginDate = this.LastLoginDate;
			user.LastPasswordChangedDate = this.LastPasswordChangedDate;
			user.CreationDate = this.CreationDate;
			user.IsOnLine = this.IsOnLine;
			user.IsLockedOut = this.IsLockedOut;
			user.LastLockedOutDate = this.LastLockedOutDate;
			user.FailedPasswordAttemptCount = this.FailedPasswordAttemptCount;
			user.FailedPasswordAttemptWindowStart = this.FailedPasswordAttemptWindowStart;
			user.ApiKey = this.ApiKey;
			user.PersonId = this.PersonId;
			user.CreatedDateTime = this.CreatedDateTime;
			user.ModifiedDateTime = this.ModifiedDateTime;
			user.CreatedByPersonId = this.CreatedByPersonId;
			user.ModifiedByPersonId = this.ModifiedByPersonId;
			user.Id = this.Id;
			user.Guid = this.Guid;
		}
	}
}
