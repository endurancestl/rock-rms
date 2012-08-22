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
using System.Linq;

using Rock.Data;

namespace Rock.Core
{
	/// <summary>
	/// Metric Service class
	/// </summary>
	public partial class MetricService : Service<Metric, MetricDTO>
	{
		/// <summary>
		/// Creates a new model
		/// </summary>
		public override Metric CreateNew()
		{
			return new Metric();
		}

		/// <summary>
		/// Query DTO objects
		/// </summary>
		/// <returns>A queryable list of DTO objects</returns>
		public override IQueryable<MetricDTO> QueryableDTO()
		{
			return this.Queryable().Select( m => new MetricDTO()
				{
					IsSystem = m.IsSystem,
					Type = m.Type,
					Category = m.Category,
					Title = m.Title,
					Subtitle = m.Subtitle,
					Description = m.Description,
					MinValue = m.MinValue,
					MaxValue = m.MaxValue,
					CollectionFrequency = m.CollectionFrequency,
					LastCollected = m.LastCollected,
					Source = m.Source,
					SourceSQL = m.SourceSQL,
					Order = m.Order,
					CreatedDateTime = m.CreatedDateTime,
					ModifiedDateTime = m.ModifiedDateTime,
					CreatedByPersonId = m.CreatedByPersonId,
					ModifiedByPersonId = m.ModifiedByPersonId,
					Id = m.Id,
					Guid = m.Guid,				});
		}
	}
}
