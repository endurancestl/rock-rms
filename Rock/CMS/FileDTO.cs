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
	/// Data Transfer Object for File object
	/// </summary>
	public partial class FileDTO : DTO<File>
	{

#pragma warning disable 1591
		public bool IsTemporary { get; set; }
		public bool IsSystem { get; set; }
		public Byte[] Data { get; set; }
		public string Url { get; set; }
		public string FileName { get; set; }
		public string MimeType { get; set; }
		public string Description { get; set; }
#pragma warning restore 1591

		/// <summary>
		/// Instantiates a new DTO object
		/// </summary>
		public FileDTO ()
		{
		}

		/// <summary>
		/// Instantiates a new DTO object from the model
		/// </summary>
		/// <param name="file"></param>
		public FileDTO ( File file )
		{
			CopyFromModel( file );
		}

		/// <summary>
		/// Copies the model property values to the DTO properties
		/// </summary>
		/// <param name="file"></param>
		public override void CopyFromModel( File file )
		{
			this.IsTemporary = file.IsTemporary;
			this.IsSystem = file.IsSystem;
			this.Data = file.Data;
			this.Url = file.Url;
			this.FileName = file.FileName;
			this.MimeType = file.MimeType;
			this.Description = file.Description;
			this.CreatedDateTime = file.CreatedDateTime;
			this.ModifiedDateTime = file.ModifiedDateTime;
			this.CreatedByPersonId = file.CreatedByPersonId;
			this.ModifiedByPersonId = file.ModifiedByPersonId;
			this.Id = file.Id;
			this.Guid = file.Guid;
		}

		/// <summary>
		/// Copies the DTO property values to the model properties
		/// </summary>
		/// <param name="file"></param>
		public override void CopyToModel ( File file )
		{
			file.IsTemporary = this.IsTemporary;
			file.IsSystem = this.IsSystem;
			file.Data = this.Data;
			file.Url = this.Url;
			file.FileName = this.FileName;
			file.MimeType = this.MimeType;
			file.Description = this.Description;
			file.CreatedDateTime = this.CreatedDateTime;
			file.ModifiedDateTime = this.ModifiedDateTime;
			file.CreatedByPersonId = this.CreatedByPersonId;
			file.ModifiedByPersonId = this.ModifiedByPersonId;
			file.Id = this.Id;
			file.Guid = this.Guid;
		}
	}
}
