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

using Rock.Core;

namespace Rock.Rest.Core
{
	/// <summary>
	/// Metrics REST API
	/// </summary>
	public partial class MetricsController : Rock.Rest.ApiController<Rock.Core.Metric, Rock.Core.MetricDTO>
	{
		public MetricsController() : base( new Rock.Core.MetricService() ) { } 
	}
}
