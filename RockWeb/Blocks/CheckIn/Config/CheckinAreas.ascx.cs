﻿// <copyright>
// Copyright by the Spark Development Network
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// </copyright>
//
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Rock;
using Rock.Constants;
using Rock.Data;
using Rock.Model;
using Rock.Security;
using Rock.Web.Cache;
using Rock.Web.UI;
using Rock.Web.UI.Controls;

namespace RockWeb.Blocks.CheckIn.Config
{
    /// <summary>
    ///
    /// </summary>
    [DisplayName( "Check-in Areas" )]
    [Category( "Check-in > Configuration" )]
    [Description( "Configure Check-in areas and groups." )]
    public partial class CheckinAreas : RockBlock, ISecondaryBlock
    {

        #region Properties

        private GroupType _checkinType = null;
        private List<Guid> _groupTypes = new List<Guid>();
        private List<Guid> _groups = new List<Guid>();
        private List<Guid> _expandedRows = new List<Guid>();

        private Guid? _currentGroupTypeGuid = null;
        private Guid? _currentGroupGuid = null;

        #endregion

        #region Base Control Methods

        protected override void LoadViewState( object savedState )
        {
            base.LoadViewState( savedState );

            _currentGroupTypeGuid = ViewState["CurrentGroupTypeGuid"] as Guid?;
            _currentGroupGuid = ViewState["CurrentGroupGuid"] as Guid?;

            using ( var rockContext = new RockContext() )
            {
                Group group = null;
                if ( _currentGroupGuid.HasValue )
                {
                    group = new GroupService( rockContext ).Get( _currentGroupGuid.Value );
                    if ( group != null )
                    {
                        checkinGroup.CreateGroupAttributeControls( group, rockContext );
                    }
                }
            }
        }

        protected override void OnInit( EventArgs e )
        {
            base.OnInit( e );

            BuildRows( !Page.IsPostBack );

            RegisterScript();
        }

        protected override void OnLoad( EventArgs e )
        {
            base.OnLoad( e );

            nbDeleteWarning.Visible = false;
            nbSaveSuccess.Visible = false;

            if ( _checkinType == null )
            {
                pnlDetails.Visible = false;
            }
            else
            {
                if ( Page.IsPostBack )
                {
                    // handle sort events
                    string postbackArgs = Request.Params["__EVENTARGUMENT"];
                    if ( !string.IsNullOrWhiteSpace( postbackArgs ) )
                    {
                        string[] nameValue = postbackArgs.Split( new char[] { ':' } );
                        if ( nameValue.Count() == 2 )
                        {
                            string eventParam = nameValue[0];
                            switch ( eventParam )
                            {
                                case "re-order-area":
                                case "re-order-group":
                                    {
                                        string[] values = nameValue[1].Split( new char[] { ';' } );
                                        if ( values.Count() == 2 )
                                        {
                                            SortRows( eventParam, values );
                                        }
                                        break;
                                    }

                                case "select-area":
                                    {
                                        SelectArea( nameValue[1].AsGuid() );
                                        break;
                                    }

                                case "select-group":
                                    {
                                        SelectGroup( nameValue[1].AsGuid() );
                                        break;
                                    }
                            }
                        }
                    }
                }
            }
        }

        protected override object SaveViewState()
        {
            ViewState["CurrentGroupTypeGuid"] = _currentGroupTypeGuid;
            ViewState["CurrentGroupGuid"] = _currentGroupGuid;

            return base.SaveViewState();
        }
        #endregion

        #region Events

        #region Row Events

        protected void lbAddArea_Click( object sender, EventArgs e )
        {
            using ( var rockContext = new RockContext() )
            {
                var groupTypeService = new GroupTypeService( rockContext );
                var parentGroupType = groupTypeService.Get( PageParameter( "CheckInTypeId" ).AsInteger() );

                if ( parentGroupType != null )
                {
                    Guid newGuid = Guid.NewGuid();

                    var checkinArea = new GroupType();
                    checkinArea.Guid = newGuid;
                    checkinArea.Name = "New Area";
                    checkinArea.IsSystem = false;
                    checkinArea.ShowInNavigation = false;
                    checkinArea.TakesAttendance = true;
                    checkinArea.AttendanceRule = AttendanceRule.None;
                    checkinArea.AttendancePrintTo = PrintTo.Default;
                    checkinArea.AllowMultipleLocations = true;
                    checkinArea.EnableLocationSchedules = true;
                    checkinArea.Order = parentGroupType.ChildGroupTypes.Any() ? parentGroupType.ChildGroupTypes.Max( t => t.Order ) + 1 : 0;

                    GroupTypeRole defaultRole = new GroupTypeRole();
                    defaultRole.Name = "Member";
                    checkinArea.Roles.Add( defaultRole );

                    parentGroupType.ChildGroupTypes.Add( checkinArea );

                    rockContext.SaveChanges();

                    GroupTypeCache.Flush( parentGroupType.Id );
                    Rock.CheckIn.KioskDevice.FlushAll();

                    SelectArea( newGuid );
                }
            }

            BuildRows();
        }

        private void CheckinAreaRow_AddAreaClick( object sender, EventArgs e )
        {
            var parentRow = sender as CheckinAreaRow;
            parentRow.Expanded = true;

            using ( var rockContext = new RockContext() )
            {
                var groupTypeService = new GroupTypeService( rockContext );
                var parentArea = groupTypeService.Get( parentRow.GroupTypeGuid );
                if ( parentArea != null )
                {
                    Guid newGuid = Guid.NewGuid();

                    var checkinArea = new GroupType();
                    checkinArea.Guid = newGuid;
                    checkinArea.Name = "New Area";
                    checkinArea.IsSystem = false;
                    checkinArea.ShowInNavigation = false;
                    checkinArea.TakesAttendance = true;
                    checkinArea.AttendanceRule = AttendanceRule.None;
                    checkinArea.AttendancePrintTo = PrintTo.Default;
                    checkinArea.AllowMultipleLocations = true;
                    checkinArea.EnableLocationSchedules = true;
                    checkinArea.Order = parentArea.ChildGroupTypes.Any() ? parentArea.ChildGroupTypes.Max( t => t.Order ) + 1 : 0;

                    GroupTypeRole defaultRole = new GroupTypeRole();
                    defaultRole.Name = "Member";
                    checkinArea.Roles.Add( defaultRole );

                    parentArea.ChildGroupTypes.Add( checkinArea );

                    rockContext.SaveChanges();

                    GroupTypeCache.Flush( parentArea.Id );
                    Rock.CheckIn.KioskDevice.FlushAll();

                    SelectArea( newGuid );
                }
            }

            BuildRows();
        }

        private void CheckinAreaRow_AddGroupClick( object sender, EventArgs e )
        {
            var parentRow = sender as CheckinAreaRow;
            parentRow.Expanded = true;

            using ( var rockContext = new RockContext() )
            {
                var groupTypeService = new GroupTypeService( rockContext );
                var parentArea = groupTypeService.Get( parentRow.GroupTypeGuid );
                if ( parentArea != null )
                {
                    Guid newGuid = Guid.NewGuid();

                    var checkinGroup = new Group();
                    checkinGroup.Guid = newGuid;
                    checkinGroup.Name = "New Group";
                    checkinGroup.IsActive = true;
                    checkinGroup.IsPublic = true;
                    checkinGroup.IsSystem = false;
                    checkinGroup.Order = parentArea.Groups.Any() ? parentArea.Groups.Max( t => t.Order ) + 1 : 0;

                    parentArea.Groups.Add( checkinGroup );

                    rockContext.SaveChanges();

                    GroupTypeCache.Flush( parentArea.Id );
                    Rock.CheckIn.KioskDevice.FlushAll();

                    SelectGroup( newGuid );
                }
            }

            BuildRows();
        }

        private void CheckinAreaRow_DeleteAreaClick( object sender, EventArgs e )
        {
            var row = sender as CheckinAreaRow;

            using ( var rockContext = new RockContext() )
            {
                var groupTypeService = new GroupTypeService( rockContext );
                var groupType = groupTypeService.Get( row.GroupTypeGuid );
                if ( groupType != null )
                {
                    // Warn if this GroupType or any of its child grouptypes (recursive) is being used as an Inherited Group Type. Probably shouldn't happen, but just in case
                    if ( IsInheritedGroupTypeRecursive( groupType, groupTypeService ) )
                    {
                        nbDeleteWarning.Text = "WARNING - Cannot delete. This group type or one of its child group types is assigned as an inherited group type.";
                        nbDeleteWarning.Visible = true;
                        return;
                    }

                    string errorMessage;
                    if ( !groupTypeService.CanDelete( groupType, out errorMessage ) )
                    {
                        nbDeleteWarning.Text = "WARNING - Cannot Delete: " + errorMessage;
                        nbDeleteWarning.Visible = true;
                        return;
                    }

                    int id = groupType.Id;

                    groupType.ParentGroupTypes.Clear();
                    groupType.ChildGroupTypes.Clear();

                    groupTypeService.Delete( groupType );
                    rockContext.SaveChanges();

                    GroupTypeCache.Flush( id );
                    Rock.CheckIn.KioskDevice.FlushAll();

                    SelectArea( null );
                }
            }

            BuildRows();
        }

        private void CheckinGroupRow_AddGroupClick( object sender, EventArgs e )
        {
            var parentRow = sender as CheckinGroupRow;
            parentRow.Expanded = true;

            using ( var rockContext = new RockContext() )
            {
                var groupService = new GroupService( rockContext );
                var parentGroup = groupService.Get( parentRow.GroupGuid );
                if ( parentGroup != null )
                {
                    Guid newGuid = Guid.NewGuid();

                    var checkinGroup = new Group();
                    checkinGroup.Guid = newGuid;
                    checkinGroup.GroupTypeId = parentGroup.GroupTypeId;
                    checkinGroup.Name = "New Group";
                    checkinGroup.IsActive = true;
                    checkinGroup.IsPublic = true;
                    checkinGroup.IsSystem = false;
                    checkinGroup.Order = parentGroup.Groups.Any() ? parentGroup.Groups.Max( t => t.Order ) + 1 : 0;

                    groupService.Add( checkinGroup );

                    rockContext.SaveChanges();

                    Rock.CheckIn.KioskDevice.FlushAll();

                    SelectGroup( newGuid );
                }
            }

            BuildRows();
        }

        private void CheckinGroupRow_DeleteGroupClick( object sender, EventArgs e )
        {
            var row = sender as CheckinGroupRow;

            using ( var rockContext = new RockContext() )
            {
                var groupService = new GroupService( rockContext );
                var group = groupService.Get( row.GroupGuid );
                if ( group != null )
                {
                    string errorMessage;
                    if ( !groupService.CanDelete( group, out errorMessage ) )
                    {
                        nbDeleteWarning.Text = "WARNING - Cannot Delete: " + errorMessage;
                        nbDeleteWarning.Visible = true;
                        return;
                    }

                    groupService.Delete( group );
                    rockContext.SaveChanges();

                    Rock.CheckIn.KioskDevice.FlushAll();

                    SelectGroup( null );
                }
            }

            BuildRows();
        }

        #endregion

        #region Detail Events

        protected void checkinArea_AddCheckinLabelClick( object sender, EventArgs e )
        {
            Guid binaryFileTypeCheckinLabelGuid = new Guid( Rock.SystemGuid.BinaryFiletype.CHECKIN_LABEL );

            var binaryFileService = new BinaryFileService( new RockContext() );

            ddlCheckinLabel.Items.Clear();
            ddlCheckinLabel.AutoPostBack = false;
            ddlCheckinLabel.Required = true;
            ddlCheckinLabel.Items.Add( new ListItem() );

            var list = binaryFileService.Queryable().Where( a => a.BinaryFileType.Guid.Equals( binaryFileTypeCheckinLabelGuid ) && a.IsTemporary == false ).OrderBy( a => a.FileName ).ToList();

            foreach ( var item in list )
            {
                // add checkinlabels to dropdownlist if they aren't already a checkin label for this grouptype
                if ( !checkinArea.CheckinLabels.Select( a => a.BinaryFileGuid ).Contains( item.Guid ) )
                {
                    ddlCheckinLabel.Items.Add( new ListItem( item.FileName, item.Guid.ToString() ) );
                }
            }

            mdAddCheckinLabel.Show();
        }

        protected void checkinArea_DeleteCheckinLabelClick( object sender, RowEventArgs e )
        {
            string attributeKey = e.RowKeyValue as string;

            var label = checkinArea.CheckinLabels.FirstOrDefault( a => a.AttributeKey == attributeKey );
            checkinArea.CheckinLabels.Remove( label );

            hfIsDirty.Value = "true";
        }

        protected void mdAddCheckinLabel_SaveClick( object sender, EventArgs e )
        {
            var checkinLabelAttributeInfo = new CheckinArea.CheckinLabelAttributeInfo();
            checkinLabelAttributeInfo.BinaryFileGuid = ddlCheckinLabel.SelectedValue.AsGuid();
            checkinLabelAttributeInfo.FileName = ddlCheckinLabel.SelectedItem.Text;

            // have the attribute key just be the filename without spaces, but make sure it is not a duplicate
            string attributeKey = checkinLabelAttributeInfo.FileName.Replace( " ", string.Empty );
            checkinLabelAttributeInfo.AttributeKey = attributeKey;
            int duplicateInc = 1;
            while ( checkinArea.CheckinLabels.Select( a => a.AttributeKey ).Contains( attributeKey + duplicateInc.ToString() ) )
            {
                // append number to end until it isn't a duplicate
                checkinLabelAttributeInfo.AttributeKey += attributeKey + duplicateInc.ToString();
                duplicateInc++;
            }

            checkinArea.CheckinLabels.Add( checkinLabelAttributeInfo );

            mdAddCheckinLabel.Hide();

            hfIsDirty.Value = "true";
        }

        protected void checkinGroup_AddLocationClick( object sender, EventArgs e )
        {
            locationPicker.SetValue( null );
            mdLocationPicker.Show();
        }

        protected void checkinGroup_DeleteLocationClick( object sender, RowEventArgs e )
        {
            var location = checkinGroup.Locations.FirstOrDefault( a => a.LocationId == e.RowKeyId );
            checkinGroup.Locations.Remove( location );

            hfIsDirty.Value = "true";
        }

        protected void mdLocationPicker_SaveClick( object sender, EventArgs e )
        {
            // Add the location (ignore if they didn't pick one, or they picked one that already is selected)
            var location = new LocationService( new RockContext() ).Get( locationPicker.SelectedValue.AsInteger() );
            if ( location != null )
            {
                if ( !checkinGroup.Locations.Any( a => a.LocationId == location.Id ) )
                {
                    var gridItem = new CheckinGroup.LocationGridItem();
                    gridItem.LocationId = location.Id;
                    gridItem.Name = location.Name;
                    gridItem.FullNamePath = location.Name;
                    gridItem.ParentLocationId = location.ParentLocationId;
                    var parentLocation = location.ParentLocation;
                    while ( parentLocation != null )
                    {
                        gridItem.FullNamePath = parentLocation.Name + " > " + gridItem.FullNamePath;
                        parentLocation = parentLocation.ParentLocation;
                    }

                    checkinGroup.Locations.Add( gridItem );

                    hfIsDirty.Value = "true";
                }
            }

            mdLocationPicker.Hide();
        }


        protected void btnSave_Click( object sender, EventArgs e )
        {
            using ( var rockContext = new RockContext() )
            {
                var attributeService = new AttributeService( rockContext );

                if ( checkinArea.Visible )
                {
                    var groupTypeService = new GroupTypeService( rockContext );
                    var groupType = groupTypeService.Get( checkinArea.GroupTypeGuid );
                    if ( groupType != null )
                    {
                        groupType.LoadAttributes( rockContext );
                        checkinArea.GetGroupTypeValues( groupType );

                        if ( groupType.IsValid )
                        {
                            rockContext.SaveChanges();
                            groupType.SaveAttributeValues( rockContext );

                            bool AttributesUpdated = false;

                            // rebuild the CheckinLabel attributes from the UI (brute-force)
                            foreach ( var labelAttribute in CheckinArea.GetCheckinLabelAttributes( groupType.Attributes ) )
                            {
                                var attribute = attributeService.Get( labelAttribute.Value.Guid );
                                Rock.Web.Cache.AttributeCache.Flush( attribute.Id );
                                attributeService.Delete( attribute );
                                AttributesUpdated = true;
                            }

                            // Make sure default role is set
                            if ( !groupType.DefaultGroupRoleId.HasValue && groupType.Roles.Any() )
                            {
                                groupType.DefaultGroupRoleId = groupType.Roles.First().Id;
                            }

                            rockContext.SaveChanges();

                            int labelOrder = 0;
                            int binaryFileFieldTypeID = FieldTypeCache.Read( Rock.SystemGuid.FieldType.BINARY_FILE.AsGuid() ).Id;
                            foreach ( var checkinLabelAttributeInfo in checkinArea.CheckinLabels )
                            {
                                var attribute = new Rock.Model.Attribute();
                                attribute.AttributeQualifiers.Add( new AttributeQualifier { Key = "binaryFileType", Value = Rock.SystemGuid.BinaryFiletype.CHECKIN_LABEL } );
                                attribute.Guid = Guid.NewGuid();
                                attribute.FieldTypeId = binaryFileFieldTypeID;
                                attribute.EntityTypeId = EntityTypeCache.GetId( typeof( GroupType ) );
                                attribute.EntityTypeQualifierColumn = "Id";
                                attribute.EntityTypeQualifierValue = groupType.Id.ToString();
                                attribute.DefaultValue = checkinLabelAttributeInfo.BinaryFileGuid.ToString();
                                attribute.Key = checkinLabelAttributeInfo.AttributeKey;
                                attribute.Name = checkinLabelAttributeInfo.FileName;
                                attribute.Order = labelOrder++;

                                if ( !attribute.IsValid )
                                {
                                    return;
                                }

                                attributeService.Add( attribute );
                                AttributesUpdated = true;

                            }

                            rockContext.SaveChanges();

                            GroupTypeCache.Flush( groupType.Id );
                            Rock.CheckIn.KioskDevice.FlushAll();

                            if ( AttributesUpdated )
                            {
                                AttributeCache.FlushEntityAttributes();
                            }

                            nbSaveSuccess.Visible = true;
                            BuildRows();
                        }
                    }
                }

                if ( checkinGroup.Visible )
                {
                    var groupService = new GroupService( rockContext );
                    var groupLocationService = new GroupLocationService( rockContext );

                    var group = groupService.Get( checkinGroup.GroupGuid );
                    if ( group != null )
                    {
                        group.LoadAttributes( rockContext );
                        checkinGroup.GetGroupValues( group );

                        // populate groupLocations with whatever is currently in the grid, with just enough info to repopulate it and save it later
                        var newLocationIds = checkinGroup.Locations.Select( l => l.LocationId ).ToList();
                        foreach ( var groupLocation in group.GroupLocations.Where( l => !newLocationIds.Contains( l.LocationId ) ).ToList() )
                        {
                            groupLocationService.Delete( groupLocation );
                            group.GroupLocations.Remove( groupLocation );
                        }

                        var existingLocationIds = group.GroupLocations.Select( g => g.LocationId ).ToList();
                        foreach ( var item in checkinGroup.Locations.Where( l => !existingLocationIds.Contains( l.LocationId ) ).ToList() )
                        {
                            var groupLocation = new GroupLocation();
                            groupLocation.LocationId = item.LocationId;
                            group.GroupLocations.Add( groupLocation );
                        }


                        if ( group.IsValid )
                        {
                            rockContext.SaveChanges();
                            group.SaveAttributeValues( rockContext );

                            Rock.CheckIn.KioskDevice.FlushAll();
                            nbSaveSuccess.Visible = true;
                            BuildRows();
                        }
                    }
                }
            }

            hfIsDirty.Value = "false";
        }

        #endregion

        #endregion

        #region Methods

        private void BuildRows( bool setValues = true )
        {
            _groupTypes = new List<Guid>();
            _groups = new List<Guid>();
            _expandedRows = new List<Guid>();

            foreach ( var areaRow in phRows.ControlsOfTypeRecursive<CheckinAreaRow>() )
            {
                if ( areaRow.Expanded )
                {
                    _expandedRows.Add( areaRow.GroupTypeGuid );
                }
            }

            foreach ( var groupRow in phRows.ControlsOfTypeRecursive<CheckinGroupRow>() )
            {
                if ( groupRow.Expanded )
                {
                    _expandedRows.Add( groupRow.GroupGuid );
                }
            }

            phRows.Controls.Clear();

            using ( var rockContext = new RockContext() )
            {
                _checkinType = new GroupTypeService( rockContext ).Get( PageParameter( "CheckInTypeId" ).AsInteger() );
                if ( _checkinType != null )
                {
                    foreach ( var groupType in _checkinType.ChildGroupTypes
                        .Where( t => t.Id != _checkinType.Id )
                        .OrderBy( t => t.Order )
                        .ThenBy( t => t.Name ) )
                    {
                        BuildCheckinAreaRow( groupType, phRows, setValues );
                    }
                }
            }

        }

        private void BuildCheckinAreaRow( GroupType groupType, Control parentControl, bool setValues )
        {

            if ( groupType != null && !_groupTypes.Contains( groupType.Guid ) &&
                ( groupType.GroupTypePurposeValue == null || !groupType.GroupTypePurposeValue.Guid.Equals( Rock.SystemGuid.DefinedValue.GROUPTYPE_PURPOSE_CHECKIN_FILTER.AsGuid() ) ) )
            {
                _groupTypes.Add( groupType.Guid );

                var checkinAreaRow = new CheckinAreaRow();
                checkinAreaRow.ID = "CheckinAreaRow_" + groupType.Guid.ToString( "N" );
                checkinAreaRow.SetGroupType( groupType );
                checkinAreaRow.AddAreaClick += CheckinAreaRow_AddAreaClick;
                checkinAreaRow.AddGroupClick += CheckinAreaRow_AddGroupClick;
                checkinAreaRow.DeleteAreaClick += CheckinAreaRow_DeleteAreaClick;
                parentControl.Controls.Add( checkinAreaRow );

                if ( setValues )
                {
                    checkinAreaRow.Expanded = true; //_expandedRows.Contains( groupType.Guid );
                    checkinAreaRow.Selected = checkinArea.Visible && _currentGroupTypeGuid.HasValue && groupType.Guid.Equals( _currentGroupTypeGuid.Value );
                }

                foreach ( var childGroupType in groupType.ChildGroupTypes
                    .Where( t => t.Id != groupType.Id )
                    .OrderBy( t => t.Order )
                    .ThenBy( t => t.Name ) )
                {
                    BuildCheckinAreaRow( childGroupType, checkinAreaRow, setValues );
                }

                // Find the groups of this type, who's parent is null, or another group type ( "root" groups ).
                var allGroupIds = groupType.Groups.Select( g => g.Id ).ToList();
                foreach ( var childGroup in groupType.Groups
                    .Where( g =>
                        !g.ParentGroupId.HasValue ||
                        !allGroupIds.Contains( g.ParentGroupId.Value ) )
                    .OrderBy( a => a.Order )
                    .ThenBy( a => a.Name ) )
                {
                    BuildCheckinGroupRow( childGroup, checkinAreaRow, setValues );
                }

            }
        }

        private void BuildCheckinGroupRow( Group group, Control parentControl, bool setValues )
        {
            if ( group != null && !_groups.Contains( group.Guid ) )
            {
                var checkinGroupRow = new CheckinGroupRow();
                checkinGroupRow.ID = "checkinGroupRow_" + group.Guid.ToString( "N" );
                checkinGroupRow.SetGroup( group );
                checkinGroupRow.AddGroupClick += CheckinGroupRow_AddGroupClick;
                checkinGroupRow.DeleteGroupClick += CheckinGroupRow_DeleteGroupClick;
                parentControl.Controls.Add( checkinGroupRow );

                if ( setValues )
                {
                    checkinGroupRow.Expanded = true; // _expandedRows.Contains( group.Guid );
                    checkinGroupRow.Selected = checkinGroup.Visible && _currentGroupGuid.HasValue && group.Guid.Equals( _currentGroupGuid.Value );
                }

                foreach ( var childGroup in group.Groups
                    .Where( g => g.GroupTypeId == group.GroupTypeId )
                    .OrderBy( a => a.Order )
                    .ThenBy( a => a.Name ) )
                {
                    BuildCheckinGroupRow( childGroup, checkinGroupRow, setValues );
                }
            }
        }

        private void SortRows( string eventParam, string[] values )
        {
            var groupTypeIds = new List<int>();

            using ( var rockContext = new RockContext() )
            {
                if ( eventParam.Equals( "re-order-area" ) )
                {
                    Guid groupTypeGuid = new Guid( values[0] );
                    int newIndex = int.Parse( values[1] );

                    var allRows = phRows.ControlsOfTypeRecursive<CheckinAreaRow>();
                    var sortedRow = allRows.FirstOrDefault( a => a.GroupTypeGuid.Equals( groupTypeGuid ) );
                    if ( sortedRow != null )
                    {
                        Control parentControl = sortedRow.Parent;

                        var siblingRows = allRows
                            .Where( a => a.Parent.ClientID == sortedRow.Parent.ClientID )
                            .ToList();

                        int oldIndex = siblingRows.IndexOf( sortedRow );

                        var groupTypeService = new GroupTypeService( rockContext );
                        var groupTypes = new List<GroupType>();
                        foreach ( var siblingGuid in siblingRows.Select( a => a.GroupTypeGuid ) )
                        {
                            var groupType = groupTypeService.Get( siblingGuid );
                            if ( groupType != null )
                            {
                                groupTypes.Add( groupType );
                                groupTypeIds.Add( groupType.Id );
                            }
                        }

                        groupTypeService.Reorder( groupTypes, oldIndex, newIndex );
                    }
                }
                else if ( eventParam.Equals( "re-order-group" ) )
                {
                    Guid groupGuid = new Guid( values[0] );
                    int newIndex = int.Parse( values[1] );

                    var allRows = phRows.ControlsOfTypeRecursive<CheckinGroupRow>();
                    var sortedRow = allRows.FirstOrDefault( a => a.GroupGuid.Equals( groupGuid ) );
                    if ( sortedRow != null )
                    {
                        Control parentControl = sortedRow.Parent;

                        var siblingRows = allRows
                            .Where( a => a.Parent.ClientID == sortedRow.Parent.ClientID )
                            .ToList();

                        int oldIndex = siblingRows.IndexOf( sortedRow );

                        var groupService = new GroupService( rockContext );
                        var groups = new List<Group>();
                        foreach ( var siblingGuid in siblingRows.Select( a => a.GroupGuid ) )
                        {
                            var group = groupService.Get( siblingGuid );
                            if ( group != null )
                            {
                                groups.Add( group );
                            }
                        }

                        groupService.Reorder( groups, oldIndex, newIndex );
                    }
                }

                rockContext.SaveChanges();
            }

            foreach( int id in groupTypeIds )
            {
                GroupTypeCache.Flush( id );
            }

            Rock.CheckIn.KioskDevice.FlushAll();

            BuildRows();
        }

        private void ExpandGroupRowParent( CheckinGroupRow groupRow )
        {
            if ( groupRow.Parent is CheckinGroupRow )
            {
                ( (CheckinGroupRow)groupRow.Parent ).Expanded = true;
            }
            else if ( groupRow.Parent is CheckinAreaRow )
            {
                ( (CheckinAreaRow)groupRow.Parent ).Expanded = true;
            }
        }

        /// <summary>
        /// Determines whether [is inherited group type recursive] [the specified group type].
        /// </summary>
        /// <param name="groupType">Type of the group.</param>
        /// <param name="rockContext">The rock context.</param>
        /// <returns></returns>
        private bool IsInheritedGroupTypeRecursive( GroupType groupType, GroupTypeService groupTypeService, List<int> typesChecked = null )
        {
            // Track the groups that have been checked since group types can have themselves as a child
            typesChecked = typesChecked ?? new List<int>();
            if ( !typesChecked.Contains( groupType.Id ) )
            {
                typesChecked.Add( groupType.Id );

                if ( groupTypeService.Queryable().Any( a => a.InheritedGroupType.Guid == groupType.Guid ) )
                {
                    return true;
                }

                foreach ( var childGroupType in groupType.ChildGroupTypes.Where( t => !typesChecked.Contains( t.Id ) ) )
                {
                    if ( IsInheritedGroupTypeRecursive( childGroupType, groupTypeService, typesChecked ) )
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        private void SelectArea( Guid? groupTypeGuid )
        {
            hfIsDirty.Value = "false";

            checkinArea.Visible = false;
            checkinGroup.Visible = false;
            btnSave.Visible = false;

            if ( groupTypeGuid.HasValue )
            {
                using ( var rockContext = new RockContext() )
                {
                    var groupTypeService = new GroupTypeService( rockContext );
                    var groupType = groupTypeService.Get( groupTypeGuid.Value );
                    if ( groupType != null )
                    {
                        _currentGroupTypeGuid = groupType.Guid;

                        checkinArea.SetGroupType( groupType );
                        checkinArea.CheckinLabels = new List<CheckinArea.CheckinLabelAttributeInfo>();

                        groupType.LoadAttributes( rockContext );
                        List<string> labelAttributeKeys = CheckinArea.GetCheckinLabelAttributes( groupType.Attributes )
                            .OrderBy( a => a.Value.Order )
                            .Select( a => a.Key ).ToList();
                        BinaryFileService binaryFileService = new BinaryFileService( rockContext );

                        foreach ( string key in labelAttributeKeys )
                        {
                            var attributeValue = groupType.GetAttributeValue( key );
                            Guid binaryFileGuid = attributeValue.AsGuid();
                            var fileName = binaryFileService.Queryable().Where( a => a.Guid == binaryFileGuid ).Select( a => a.FileName ).FirstOrDefault();
                            if ( fileName != null )
                            {
                                checkinArea.CheckinLabels.Add( new CheckinArea.CheckinLabelAttributeInfo { AttributeKey = key, BinaryFileGuid = binaryFileGuid, FileName = fileName } );
                            }
                        }

                        checkinArea.Visible = true;
                        btnSave.Visible = true;

                    }
                    else
                    {
                        _currentGroupTypeGuid = null;
                    }
                }
            }
            else
            {
                _currentGroupTypeGuid = null;
            }

            BuildRows();

        }

        private void SelectGroup( Guid? groupGuid )
        {
            hfIsDirty.Value = "false";

            checkinArea.Visible = false;
            checkinGroup.Visible = false;
            btnSave.Visible = false;

            if ( groupGuid.HasValue )
            {
                using ( var rockContext = new RockContext() )
                {
                    var groupService = new GroupService( rockContext );
                    var group = groupService.Get( groupGuid.Value );
                    if ( group != null )
                    {
                        _currentGroupGuid = group.Guid;

                        checkinGroup.SetGroup( group, rockContext );

                        var locationService = new LocationService( rockContext );
                        var locationQry = locationService.Queryable().Select( a => new { a.Id, a.ParentLocationId, a.Name } );

                        checkinGroup.Locations = new List<CheckinGroup.LocationGridItem>();
                        foreach ( var location in group.GroupLocations.Select( a => a.Location ).OrderBy( o => o.Name ) )
                        {
                            var gridItem = new CheckinGroup.LocationGridItem();
                            gridItem.LocationId = location.Id;
                            gridItem.Name = location.Name;
                            gridItem.FullNamePath = location.Name;
                            gridItem.ParentLocationId = location.ParentLocationId;

                            var parentLocationId = location.ParentLocationId;
                            while ( parentLocationId != null )
                            {
                                var parentLocation = locationQry.FirstOrDefault( a => a.Id == parentLocationId );
                                gridItem.FullNamePath = parentLocation.Name + " > " + gridItem.FullNamePath;
                                parentLocationId = parentLocation.ParentLocationId;
                            }

                            checkinGroup.Locations.Add( gridItem );
                        }

                        checkinGroup.Visible = true;
                        btnSave.Visible = true;
                    }
                    else
                    {
                        _currentGroupGuid = null;
                    }
                }
            }
            else
            {
                _currentGroupGuid = null;
                checkinGroup.CreateGroupAttributeControls( null, null );
            }

            BuildRows();

        }

        public void SetVisible( bool visible )
        {
            pnlDetails.Visible = visible;
        }

        private void RegisterScript()
        {
            string script = string.Format( @"
    window.addEventListener('beforeunload', function(e) {{
        if ( $('#{0}').val() == 'true' ) {{
            return 'You have not saved your changes. Are you sure you want to continue?';    
        }}
        return;
    }});

    $('.js-area-group-details').find('input').blur( function() {{
        $('#{0}').val('true')
    }});

    function isDirty() {{
        if ( $('#{0}').val() == 'true' ) {{
            if ( confirm('You have not saved your changes. Are you sure you want to continue?') ) {{
                return false;
            }}
            return true;
        }}
        return false;
    }}

    $('#{1}').click( function() {{
        if ( isDirty() ) {{
            return false;
        }}
    }});


", hfIsDirty.ClientID, lbAddArea.ClientID );
            ScriptManager.RegisterStartupScript( upDetail, this.GetType(), "checkinIsDirty", script, true );

        }
        #endregion

    }
}