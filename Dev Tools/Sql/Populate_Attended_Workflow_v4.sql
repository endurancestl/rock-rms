------------------------------------------------------------------------
-- This script will add data for the attended check-in system 
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Set up the check in category
------------------------------------------------------------------------
DECLARE @CategoryId int
IF NOT EXISTS(SELECT [Id] FROM Category WHERE [Name] = 'Checkin')
INSERT INTO Category ([IsSystem], [EntityTypeId], [Name], [Guid])
VALUES (1, 32, 'Checkin', '4A769688-2DAA-47DC-BBC7-0A640A5B05FC')
SET @CategoryId = SCOPE_IDENTITY()

------------------------------------------------------------------------
-- Set up the attended check in workflow
------------------------------------------------------------------------

-- Workflow Type
DECLARE @WorkflowTypeId int
SET @WorkflowTypeId = (SELECT Id FROM [WorkflowType] WHERE Guid = '6E8CD562-A1DA-4E13-A45C-853DB56E0014')
IF @WorkflowTypeId IS NOT NULL
BEGIN
	DELETE [Workflow] WHERE Id = @WorkflowTypeId
	DELETE [WorkflowType] WHERE Id = @WorkflowTypeId
END

INSERT INTO WorkFlowType ([IsSystem], [IsActive], [Name], [Description], [CategoryId], [Order], [WorkTerm], [IsPersisted], [LoggingLevel], [Guid])
VALUES (0, 1, 'Attended Checkin', 'Workflow for managing attended checkin', 	@CategoryId, 0, 'Checkin', 0, 3, '6E8CD562-A1DA-4E13-A45C-853DB56E0014')
SET @WorkflowTypeId = SCOPE_IDENTITY()

DECLARE @WorkflowActivity1 int
DECLARE @WorkflowActivity2 int
DECLARE @WorkflowActivity3 int
DECLARE @WorkflowActivity4 int
INSERT WorkflowActivityType ([IsActive], [WorkflowTypeId], [Name], [Description], [IsActivatedWithWorkflow], [Order], [Guid])
VALUES ( 1, @WorkflowTypeId,	'Family Search',	 '', 0, 0, 'B6FC7350-10E0-4255-873D-4B492B7D27FF') 
	, ( 1, @WorkflowTypeId, 'Person Search', '', 0, 1,	 '6D8CC755-0140-439A-B5A3-97D2F7681697')
	, ( 1, @WorkflowTypeId, 'Activity Search', '', 0, 2,	 '77CCAF74-AC78-45DE-8BF9-4C544B54C9DD')
	, ( 	1, @WorkflowTypeId, 'Save Attendance', '', 0, 3,	 'BF4E1CAA-25A3-4676-BCA2-FDE2C07E8210')

SELECT @WorkflowActivity1 = Id FROM WorkflowActivityType 
	WHERE Guid = 'B6FC7350-10E0-4255-873D-4B492B7D27FF'
SELECT @WorkflowActivity2 = Id FROM WorkflowActivityType 
	WHERE Guid = '6D8CC755-0140-439A-B5A3-97D2F7681697'
SELECT @WorkflowActivity3 = Id FROM WorkflowActivityType 
	WHERE Guid = '77CCAF74-AC78-45DE-8BF9-4C544B54C9DD'
SELECT @WorkflowActivity4 = Id FROM WorkflowActivityType 
	WHERE Guid = 'BF4E1CAA-25A3-4676-BCA2-FDE2C07E8210'

-- Look up BlockAttributes and Blocks for Attended Checkin
DECLARE @AttributeAdmin int
SELECT @AttributeAdmin = [ID] from [Attribute] where [Guid] = '18864DE7-F075-437D-BA72-A6054C209FA5'
DECLARE @AttributeSearch int
SELECT @AttributeSearch = [ID] from [Attribute] where [Guid] = 'C4E992EA-62AE-4211-BE5A-9EEF5131235C'
DECLARE @AttributeFamily int
SELECT @AttributeFamily = [ID] from [Attribute] where [Guid] = '338CAD91-3272-465B-B768-0AC2F07A0B40'
DECLARE @AttributeActivity int
SELECT @AttributeActivity = [ID] from [Attribute] where [Guid] = 'BEC10B87-4B19-4CD5-8952-A4D59DDA3E9C'
DECLARE @AttributeConfirmation int
SELECT @AttributeConfirmation = [ID] from [Attribute] where [Guid] = '2A71729F-E7CA-4ACD-9996-A6A661A069FD'

DECLARE @EntityIdAdmin int
SELECT @EntityIdAdmin = [ID] from [Block] where [Guid] = '9F8731AB-07DB-406F-A344-45E31D0DE301'
DECLARE @EntityIdSearch int
SELECT @EntityIdSearch = [ID] from [Block] where [Guid] = '182C9AA0-E76F-4AAF-9F61-5418EE5A0CDB'
DECLARE @EntityIdFamily int
SELECT @EntityIdFamily = [ID] from [Block] where [Guid] = '82929409-8551-413C-972A-98EDBC23F420'
DECLARE @EntityIdActivity int
SELECT @EntityIdActivity = [ID] from [Block] where [Guid] = '8C8CBBE9-2502-4FEC-804D-C0DA13C07FA4'
DECLARE @EntityIdConfirmation int
SELECT @EntityIdConfirmation = [ID] from [Block] where [Guid] = '7CC68DD4-A6EF-4B67-9FEA-A144C479E058'

-- Update current checkin blocks with new Workflow id
DELETE AttributeValue WHERE AttributeId = @AttributeAdmin
DELETE AttributeValue WHERE AttributeId = @AttributeSearch
DELETE AttributeValue WHERE AttributeId = @AttributeFamily
DELETE AttributeValue WHERE AttributeId = @AttributeActivity
DELETE AttributeValue WHERE AttributeId = @AttributeConfirmation

INSERT [AttributeValue] ([IsSystem], [AttributeId], [EntityId], [Order], [Value], [Guid])
VALUES (1, @AttributeAdmin, @EntityIdAdmin, 0, @WorkflowTypeId, '6CE9F555-8560-4BF1-951C-8E68ED0D49E9')
, (1, @AttributeSearch, @EntityIdSearch, 0, @WorkflowTypeId, '238A7D9C-C7D0-496E-89C2-1988345A6C60')
, (1, @AttributeFamily, @EntityIdFamily, 0, @WorkflowTypeId, '09688E01-72DB-4B3D-8F73-67898AE8584D')
, (1, @AttributeActivity, @EntityIdActivity, 0, @WorkflowTypeId, '317F06EB-B6E0-4A06-B644-652490D02D63')
, (1, @AttributeConfirmation, @EntityIdConfirmation, 0, @WorkflowTypeId, '17492852-0DF8-4844-9E63-B359B16D9FB6')

/* ---------------------------------------------------------------------- */
------------------------------  TEST DATA ----------------------------------
/* ---------------------------------------------------------------------- */

-- Attribute for GradeTransitionDate
INSERT INTO [AttributeValue] (IsSystem, AttributeId, Value, Guid) VALUES (0, 498, '08/01', newid())

-- GroupRoles AttendedWith and CanCheckIn for visitors
DECLARE @KnownRelationshipGroupTypeId int
SELECT @KnownRelationshipGroupTypeId = [GroupTypeId] FROM [GroupRole] WHERE [Guid] = '7BC6C12E-0CD1-4DFD-8D5B-1B35AE714C42'
INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Description, Guid, IsLeader) VALUES (0, @KnownRelationshipGroupTypeId, 'CanCheckIn', 'Family that can check in this person', 'D7980FFC-3E6D-4AD1-833D-04AA405E2741', 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Model.GroupType')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Model.GroupType', NEWID(), 0, 0)
DECLARE @GroupTypeEntityTypeId int
SET @GroupTypeEntityTypeId = (SELECT Id FROM EntityType WHERE Name = 'Rock.Model.GroupType')

DECLARE @BooleanFieldTypeId int
SET @BooleanFieldTypeId = (SELECT Id FROM FieldType WHERE guid = '1EDAFDED-DFE6-4334-B019-6EECBA89E05A')

DECLARE @DecimalFieldTypeId int
SET @DecimalFieldTypeId = (SELECT Id FROM FieldType WHERE guid = 'c757a554-3009-4214-b05d-cea2b2ea6b8f')
DELETE [Attribute] WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [Attribute] ( IsSystem, FieldTypeId, EntityTypeId, EntityTypeQualifierColumn, EntityTypeQualifierValue, [Key], Name, [Order], IsGridColumn, IsMultiValue, IsRequired, Guid)
VALUES ( 0, @DecimalFieldTypeId, @GroupTypeEntityTypeId, 'TakesAttendance', 'True', 'MinAge', 'Minimum Age', 0, 0, 0, 0, '63FA25AA-7796-4302-BF05-D96A1C390BD7')
DELETE [Attribute] WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
INSERT INTO [Attribute] ( IsSystem, FieldTypeId, EntityTypeId, EntityTypeQualifierColumn, EntityTypeQualifierValue, [Key], Name, [Order], IsGridColumn, IsMultiValue, IsRequired, Guid)
VALUES ( 0, @DecimalFieldTypeId, @GroupTypeEntityTypeId, 'TakesAttendance', 'True', 'MaxAge', 'Maximum Age', 1, 0, 0, 0, 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D')

------------------------------------------------------------------------
-- Reset Groups & GroupTypes
------------------------------------------------------------------------
DELETE GTA FROM [GroupTypeAssociation] GTA INNER JOIN [GroupType] GT ON GT.Id = GTA.GroupTypeId AND GT.Name IN ('Creativity', 'Stories Team', 'Photo', 'Storytelling', 'Worship', 'Band Green Room', 'Discipleship', 'Attendee', 'Baptism Attendee', 'Volunteer', 'Volunteer', 'Fuse', 'Middle School', '6th Grade Boy', '6th Grade Girl', '7th Grade Boy', '7th Grade Girl', '8th Grade Boy', '8th Grade Girl', 'High School', '9th Grade Boy', '9th Grade Girl', '10th Grade Boy', '10th Grade Girl', '11th Grade Boy', '11th Grade Girl', '12th Grade Boy', '12th Grade Girl', 'KidSpring', 'Nursery', 'Cuddlers', 'Wonder Way 1', 'Wonder Way 2', 'Crawlers', 'Wonder Way 3', 'Wonder Way 4', 'Walkers', 'Wonder Way 5', 'Wonder Way 6', 'Toddlers', 'Wonder Way 7', 'Wonder Way 8', 'Preschool', '2''s', 'Fire Station', 'Lil'' Spring', 'Pop''s Garage', '3''s', 'Spring Fresh', 'SpringTown Police', 'SpringTown Toys', '4''s', 'Treehouse', 'Base Camp (PS)', 'Base Camp Jr.', 'Elementary', 'Base Camp (ES)', 'ImagiNation - K', 'ImagiNation - 1st', 'Jump Street - 2nd', 'Jump Street - 3rd', 'Shockwave - 4th', 'Shockwave - 5th', 'Special Needs', 'Spring Zone', 'Spring Zone Jr.', 'KidSpring Volunteers', 'Elementary Volunteers', 'Base Camp (ES) Volunteer', 'Elementary Service Leader', 'ImagiNation Volunteer', 'Jump Street Volunteer', 'Shockwave Volunteer', 'Nursery Volunteers', 'Nursery Early Bird Volunteer', 'Nursery Service Leader', 'Wonder Way 1 Volunteer', 'Wonder Way 2 Volunteer', 'Wonder Way 3 Volunteer', 'Wonder Way 4 Volunteer', 'Wonder Way 5 Volunteer', 'Wonder Way 6 Volunteer', 'Wonder Way 7 Volunteer', 'Wonder Way 8 Volunteer', 'Preschool Volunteers', 'Base Camp Jr. Volunteer', 'Fire Station Volunteer', 'Lil'' Spring Volunteer', 'Pop''s Garage', 'Preschool Early Bird Volunteer', 'Preschool Service Leader', 'Spring Fresh Volunteer', 'SpringTown Police Volunteer', 'SpringTown Toys Volunteer', 'Treehouse Volunteer', 'Guest Services', 'Advocate', 'Character Team', 'Check-In Volunteer', 'First Time Team', 'Guest Services Service Leader', 'KidSpring Greeter', 'Production Volunteers', 'Elementary Production', 'Preschool Production', 'Special Needs Volunteers', 'Spring Zone Jr. Volunteer', 'Spring Zone Volunteer', 'Support Volunteers', 'KidSpring Office Team', 'KidSpring Trainee', 'Sunday Support Volunteer', 'Volunteer Plug-In Team', 'Volunteers', 'Campus Support', 'Community Outreach', 'Care & Outreach', 'Baptism Team', 'Prayer Team', 'Sunday Care Team', 'Creative & Technology', 'Band Green Room', 'IT Team', 'Production Team', 'Stories Team', 'Finance', 'Finance Team', 'Guest Services', 'Awake Coffee Team', 'Campus Safety', 'Equipping Tour', 'Facility Cleaning Team', 'Fuse Team', 'Green Room', 'Greeting Team', 'Guest Service Desk Team', 'Lobby Team', 'Parking Team', 'Resource Center Team', 'Usher Team', 'Volunteer Coordinator', 'Volunteer Headquarters Team')
UPDATE [Group] SET ParentGroupId = null WHERE Name in ('Creativity', 'Stories Team', 'Photo', 'Storytelling', 'Worship', 'Band Green Room', 'Discipleship', 'Attendee', 'Baptism Attendee', 'Volunteer', 'Volunteer', 'Fuse', 'Middle School', '6th Grade Boy', '6th Grade Girl', '7th Grade Boy', '7th Grade Girl', '8th Grade Boy', '8th Grade Girl', 'High School', '9th Grade Boy', '9th Grade Girl', '10th Grade Boy', '10th Grade Girl', '11th Grade Boy', '11th Grade Girl', '12th Grade Boy', '12th Grade Girl', 'KidSpring', 'Nursery', 'Cuddlers', 'Wonder Way 1', 'Wonder Way 2', 'Crawlers', 'Wonder Way 3', 'Wonder Way 4', 'Walkers', 'Wonder Way 5', 'Wonder Way 6', 'Toddlers', 'Wonder Way 7', 'Wonder Way 8', 'Preschool', '2''s', 'Fire Station', 'Lil'' Spring', 'Pop''s Garage', '3''s', 'Spring Fresh', 'SpringTown Police', 'SpringTown Toys', '4''s', 'Treehouse', 'Base Camp (PS)', 'Base Camp Jr.', 'Elementary', 'Base Camp (ES)', 'ImagiNation - K', 'ImagiNation - 1st', 'Jump Street - 2nd', 'Jump Street - 3rd', 'Shockwave - 4th', 'Shockwave - 5th', 'Special Needs', 'Spring Zone', 'Spring Zone Jr.', 'KidSpring Volunteers', 'Elementary Volunteers', 'Base Camp (ES) Volunteer', 'Elementary Service Leader', 'ImagiNation Volunteer', 'Jump Street Volunteer', 'Shockwave Volunteer', 'Nursery Volunteers', 'Nursery Early Bird Volunteer', 'Nursery Service Leader', 'Wonder Way 1 Volunteer', 'Wonder Way 2 Volunteer', 'Wonder Way 3 Volunteer', 'Wonder Way 4 Volunteer', 'Wonder Way 5 Volunteer', 'Wonder Way 6 Volunteer', 'Wonder Way 7 Volunteer', 'Wonder Way 8 Volunteer', 'Preschool Volunteers', 'Base Camp Jr. Volunteer', 'Fire Station Volunteer', 'Lil'' Spring Volunteer', 'Pop''s Garage', 'Preschool Early Bird Volunteer', 'Preschool Service Leader', 'Spring Fresh Volunteer', 'SpringTown Police Volunteer', 'SpringTown Toys Volunteer', 'Treehouse Volunteer', 'Guest Services', 'Advocate', 'Character Team', 'Check-In Volunteer', 'First Time Team', 'Guest Services Service Leader', 'KidSpring Greeter', 'Production Volunteers', 'Elementary Production', 'Preschool Production', 'Special Needs Volunteers', 'Spring Zone Jr. Volunteer', 'Spring Zone Volunteer', 'Support Volunteers', 'KidSpring Office Team', 'KidSpring Trainee', 'Sunday Support Volunteer', 'Volunteer Plug-In Team', 'Volunteers', 'Campus Support', 'Community Outreach', 'Care & Outreach', 'Baptism Team', 'Prayer Team', 'Sunday Care Team', 'Creative & Technology', 'Band Green Room', 'IT Team', 'Production Team', 'Stories Team', 'Finance', 'Finance Team', 'Guest Services', 'Awake Coffee Team', 'Campus Safety', 'Equipping Tour', 'Facility Cleaning Team', 'Fuse Team', 'Green Room', 'Greeting Team', 'Guest Service Desk Team', 'Lobby Team', 'Parking Team', 'Resource Center Team', 'Usher Team', 'Volunteer Coordinator', 'Volunteer Headquarters Team')
DELETE [Group] WHERE Name in ('Creativity', 'Stories Team', 'Photo', 'Storytelling', 'Worship', 'Band Green Room', 'Discipleship', 'Attendee', 'Baptism Attendee', 'Volunteer', 'Volunteer', 'Fuse', 'Middle School', '6th Grade Boy', '6th Grade Girl', '7th Grade Boy', '7th Grade Girl', '8th Grade Boy', '8th Grade Girl', 'High School', '9th Grade Boy', '9th Grade Girl', '10th Grade Boy', '10th Grade Girl', '11th Grade Boy', '11th Grade Girl', '12th Grade Boy', '12th Grade Girl', 'KidSpring', 'Nursery', 'Cuddlers', 'Wonder Way 1', 'Wonder Way 2', 'Crawlers', 'Wonder Way 3', 'Wonder Way 4', 'Walkers', 'Wonder Way 5', 'Wonder Way 6', 'Toddlers', 'Wonder Way 7', 'Wonder Way 8', 'Preschool', '2''s', 'Fire Station', 'Lil'' Spring', 'Pop''s Garage', '3''s', 'Spring Fresh', 'SpringTown Police', 'SpringTown Toys', '4''s', 'Treehouse', 'Base Camp (PS)', 'Base Camp Jr.', 'Elementary', 'Base Camp (ES)', 'ImagiNation - K', 'ImagiNation - 1st', 'Jump Street - 2nd', 'Jump Street - 3rd', 'Shockwave - 4th', 'Shockwave - 5th', 'Special Needs', 'Spring Zone', 'Spring Zone Jr.', 'KidSpring Volunteers', 'Elementary Volunteers', 'Base Camp (ES) Volunteer', 'Elementary Service Leader', 'ImagiNation Volunteer', 'Jump Street Volunteer', 'Shockwave Volunteer', 'Nursery Volunteers', 'Nursery Early Bird Volunteer', 'Nursery Service Leader', 'Wonder Way 1 Volunteer', 'Wonder Way 2 Volunteer', 'Wonder Way 3 Volunteer', 'Wonder Way 4 Volunteer', 'Wonder Way 5 Volunteer', 'Wonder Way 6 Volunteer', 'Wonder Way 7 Volunteer', 'Wonder Way 8 Volunteer', 'Preschool Volunteers', 'Base Camp Jr. Volunteer', 'Fire Station Volunteer', 'Lil'' Spring Volunteer', 'Pop''s Garage', 'Preschool Early Bird Volunteer', 'Preschool Service Leader', 'Spring Fresh Volunteer', 'SpringTown Police Volunteer', 'SpringTown Toys Volunteer', 'Treehouse Volunteer', 'Guest Services', 'Advocate', 'Character Team', 'Check-In Volunteer', 'First Time Team', 'Guest Services Service Leader', 'KidSpring Greeter', 'Production Volunteers', 'Elementary Production', 'Preschool Production', 'Special Needs Volunteers', 'Spring Zone Jr. Volunteer', 'Spring Zone Volunteer', 'Support Volunteers', 'KidSpring Office Team', 'KidSpring Trainee', 'Sunday Support Volunteer', 'Volunteer Plug-In Team', 'Volunteers', 'Campus Support', 'Community Outreach', 'Care & Outreach', 'Baptism Team', 'Prayer Team', 'Sunday Care Team', 'Creative & Technology', 'Band Green Room', 'IT Team', 'Production Team', 'Stories Team', 'Finance', 'Finance Team', 'Guest Services', 'Awake Coffee Team', 'Campus Safety', 'Equipping Tour', 'Facility Cleaning Team', 'Fuse Team', 'Green Room', 'Greeting Team', 'Guest Service Desk Team', 'Lobby Team', 'Parking Team', 'Resource Center Team', 'Usher Team', 'Volunteer Coordinator', 'Volunteer Headquarters Team')
DELETE [GroupType] WHERE Name in ('Creativity', 'Stories Team', 'Photo', 'Storytelling', 'Worship', 'Band Green Room', 'Discipleship', 'Attendee', 'Baptism Attendee', 'Volunteer', 'Volunteer', 'Fuse', 'Middle School', '6th Grade Boy', '6th Grade Girl', '7th Grade Boy', '7th Grade Girl', '8th Grade Boy', '8th Grade Girl', 'High School', '9th Grade Boy', '9th Grade Girl', '10th Grade Boy', '10th Grade Girl', '11th Grade Boy', '11th Grade Girl', '12th Grade Boy', '12th Grade Girl', 'KidSpring', 'Nursery', 'Cuddlers', 'Wonder Way 1', 'Wonder Way 2', 'Crawlers', 'Wonder Way 3', 'Wonder Way 4', 'Walkers', 'Wonder Way 5', 'Wonder Way 6', 'Toddlers', 'Wonder Way 7', 'Wonder Way 8', 'Preschool', '2''s', 'Fire Station', 'Lil'' Spring', 'Pop''s Garage', '3''s', 'Spring Fresh', 'SpringTown Police', 'SpringTown Toys', '4''s', 'Treehouse', 'Base Camp (PS)', 'Base Camp Jr.', 'Elementary', 'Base Camp (ES)', 'ImagiNation - K', 'ImagiNation - 1st', 'Jump Street - 2nd', 'Jump Street - 3rd', 'Shockwave - 4th', 'Shockwave - 5th', 'Special Needs', 'Spring Zone', 'Spring Zone Jr.', 'KidSpring Volunteers', 'Elementary Volunteers', 'Base Camp (ES) Volunteer', 'Elementary Service Leader', 'ImagiNation Volunteer', 'Jump Street Volunteer', 'Shockwave Volunteer', 'Nursery Volunteers', 'Nursery Early Bird Volunteer', 'Nursery Service Leader', 'Wonder Way 1 Volunteer', 'Wonder Way 2 Volunteer', 'Wonder Way 3 Volunteer', 'Wonder Way 4 Volunteer', 'Wonder Way 5 Volunteer', 'Wonder Way 6 Volunteer', 'Wonder Way 7 Volunteer', 'Wonder Way 8 Volunteer', 'Preschool Volunteers', 'Base Camp Jr. Volunteer', 'Fire Station Volunteer', 'Lil'' Spring Volunteer', 'Pop''s Garage', 'Preschool Early Bird Volunteer', 'Preschool Service Leader', 'Spring Fresh Volunteer', 'SpringTown Police Volunteer', 'SpringTown Toys Volunteer', 'Treehouse Volunteer', 'Guest Services', 'Advocate', 'Character Team', 'Check-In Volunteer', 'First Time Team', 'Guest Services Service Leader', 'KidSpring Greeter', 'Production Volunteers', 'Elementary Production', 'Preschool Production', 'Special Needs Volunteers', 'Spring Zone Jr. Volunteer', 'Spring Zone Volunteer', 'Support Volunteers', 'KidSpring Office Team', 'KidSpring Trainee', 'Sunday Support Volunteer', 'Volunteer Plug-In Team', 'Volunteers', 'Campus Support', 'Community Outreach', 'Care & Outreach', 'Baptism Team', 'Prayer Team', 'Sunday Care Team', 'Creative & Technology', 'Band Green Room', 'IT Team', 'Production Team', 'Stories Team', 'Finance', 'Finance Team', 'Guest Services', 'Awake Coffee Team', 'Campus Safety', 'Equipping Tour', 'Facility Cleaning Team', 'Fuse Team', 'Green Room', 'Greeting Team', 'Guest Service Desk Team', 'Lobby Team', 'Parking Team', 'Resource Center Team', 'Usher Team', 'Volunteer Coordinator', 'Volunteer Headquarters Team')
DECLARE @ParentGroupTypeId int
DECLARE @ChildGroupTypeId int
DECLARE @GroupRoleId int
DECLARE @TopLevelGroupTypeId int

SELECT @GroupRoleId = [Id] FROM [GroupRole] WHERE [Guid] = '00F3AC1C-71B9-4EE5-A30E-4C48C8A0BF1F'

------------------------------------------------------------------------
-- Add GroupTypes
------------------------------------------------------------------------
-- Creativity
INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Creativity', NEWID(), 1, 0, 0, 0)
SET @TopLevelGroupTypeId = SCOPE_IDENTITY()

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Stories Team', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Photo', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Storytelling', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Worship', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Band Green Room', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
--INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
--SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

-- Discipleship
INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Discipleship', NEWID(), 1, 0, 0, 0)
SET @TopLevelGroupTypeId = SCOPE_IDENTITY()

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Attendee', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Baptism Attendee', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Volunteer', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Volunteer', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

-- Fuse
INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Fuse', NEWID(), 1, 0, 0, 0)
SET @ParentGroupTypeId = SCOPE_IDENTITY()

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Middle School', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '6th Grade Boy', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '6th Grade Girl', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '7th Grade Boy', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '12.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '16.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '7th Grade Girl', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '12.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '16.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '8th Grade Boy', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '13.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '17.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '8th Grade Girl', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '13.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '17.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'High School', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '9th Grade Boy', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '9th Grade Girl', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '10th Grade Boy', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '12.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '16.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '10th Grade Girl', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '12.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '16.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '11th Grade Boy', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '13.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '17.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '11th Grade Girl', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '13.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '17.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '12th Grade Boy', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '13.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '17.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '12th Grade Girl', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '13.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '17.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

DECLARE @Level1GroupTypeId int
DECLARE @Level2GroupTypeId int
DECLARE @Level3GroupTypeId int
DECLARE @Level4GroupTypeId int

-- KidSpring
INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'KidSpring', NEWID(), 1, 0, 0, 0)
SET @Level1GroupTypeId = SCOPE_IDENTITY()

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Nursery', NEWID(), 0, 0, 0, 0)
SET @Level2GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level1GroupTypeId, @Level2GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Cuddlers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 1', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 2', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Crawlers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 3', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 4', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Walkers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 5', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 6', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Toddlers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 7', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 8', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Preschool', NEWID(), 0, 0, 0, 0)
SET @Level2GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level1GroupTypeId, @Level2GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '2''s', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Fire Station', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Lil'' Spring', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Pop''s Garage', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '3''s', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Spring Fresh', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'SpringTown Police', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'SpringTown Toys', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, '4''s', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Treehouse', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Base Camp (PS)', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Base Camp Jr.', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Elementary', NEWID(), 0, 0, 0, 0)
SET @Level2GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level1GroupTypeId, @Level2GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Base Camp (ES)', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'ImagiNation - K', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '9.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'ImagiNation - 1st', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '9.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Jump Street - 2nd', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '7.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '11.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Jump Street - 3rd', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '7.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '11.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Shockwave - 4th', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '9.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Shockwave - 5th', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '9.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Special Needs', NEWID(), 0, 0, 0, 0)
SET @Level2GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level1GroupTypeId, @Level2GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Spring Zone', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Spring Zone Jr.', NEWID(), 1, 1, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level3GroupTypeId, 0, '9.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level3GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level3GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'KidSpring Volunteers', NEWID(), 0, 0, 0, 0)
SET @Level2GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level1GroupTypeId, @Level2GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Elementary Volunteers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Base Camp (ES) Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Elementary Service Leader', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'ImagiNation Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Jump Street Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Shockwave Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Nursery Volunteers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Nursery Early Bird Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Nursery Service Leader', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 1 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 2 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 3 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 4 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 5 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 6 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 7 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Wonder Way 8 Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Preschool Volunteers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Base Camp Jr. Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Fire Station Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Lil'' Spring Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Pop''s Garage Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Preschool Early Bird Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Preschool Service Leader', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Spring Fresh Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'SpringTown Police Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'SpringTown Toys Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Treehouse Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Guest Services', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Advocate', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Character Team', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Check-In Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'First Time Team', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Guest Services Service Leader', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'KidSpring Greeter', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Production Volunteers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Elementary Production', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Preschool Production', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Special Needs Volunteers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Spring Zone Jr. Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Spring Zone Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Support Volunteers', NEWID(), 0, 0, 0, 0)
SET @Level3GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level2GroupTypeId, @Level3GroupTypeId);

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'KidSpring Office Team', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'KidSpring Trainee', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Sunday Support Volunteer', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Volunteer Plug-In Team', NEWID(), 1, 1, 0, 0)
SET @Level4GroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@Level3GroupTypeId, @Level4GroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '5.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @Level4GroupTypeId, 0, '13.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @Level4GroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @Level4GroupTypeId

-- Volunteers
INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Volunteers', NEWID(), 1, 0, 0, 0)
SET @TopLevelGroupTypeId = SCOPE_IDENTITY()

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Campus Support', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Community Outreach', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Care & Outreach', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Baptism Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Prayer Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Sunday Care Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Creative & Technology', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Band Green Room', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'IT Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Production Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Stories Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Finance', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Finance Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Guest Services', NEWID(), 0, 0, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@TopLevelGroupTypeId, @ChildGroupTypeId);
SET @ParentGroupTypeId = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Awake Coffee Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Campus Safety', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Equipping Tour', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Facility Cleaning Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Fuse Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Green Room', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Greeting Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Guest Service Desk Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Lobby Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Parking Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Resource Center Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Usher Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Volunteer Coordinator', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

INSERT INTO [GroupType] ( [IsSystem],[Name],[Guid],[AllowMultipleLocations],[TakesAttendance],[AttendanceRule],[AttendancePrintTo]) 
VALUES (0, 'Volunteer Headquarters Team', NEWID(), 1, 1, 0, 0)
SET @ChildGroupTypeId = SCOPE_IDENTITY()
INSERT INTO [GroupTypeAssociation] VALUES (@ParentGroupTypeId, @ChildGroupTypeId);
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '11.0', newid() FROM Attribute WHERE guid = '63FA25AA-7796-4302-BF05-D96A1C390BD7'
INSERT INTO [AttributeValue] (IsSystem, AttributeId, EntityId, [Order], [Value], Guid) SELECT 1, Id, @ChildGroupTypeId, 0, '15.99', newid() FROM Attribute WHERE guid = 'D05368C9-5069-49CD-B7E8-9CE8C46BB75D'
-- INSERT INTO [GroupRole] (IsSystem, GroupTypeId, Name, Guid, IsLeader) VALUES (0, @ChildGroupTypeId, 'Member', newid(), 0)
-- SET @GroupRoleId = SCOPE_IDENTITY()
UPDATE [GroupType] SET DefaultGroupRoleId = @GroupRoleId WHERE Id = @ChildGroupTypeId

------------------------------------------------------------------------
-- Add Groups
------------------------------------------------------------------------
DECLARE @TopLevelGroupId int
DECLARE @ParentGroupId int
DECLARE @GroupId int
INSERT INTO [Group] ( [IsSystem],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, GT.Id, 'Creativity', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Creativity'
SET @ParentGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Stories Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Stories Team'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Photo', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Photo'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Storytelling', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Storytelling'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Worship', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Worship'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Band Green Room', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Band Green Room'

INSERT INTO [Group] ( [IsSystem],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, GT.Id, 'Discipleship', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Discipleship'
SET @ParentGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Attendee', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Attendee'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Baptism Attendee', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Baptism Attendee'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Volunteer'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Volunteer'

INSERT INTO [Group] ( [IsSystem],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, GT.Id, 'Fuse', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Fuse'
SET @ParentGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Middle School', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Middle School'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '6th Grade Boy', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '6th Grade Boy'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '6th Grade Girl', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '6th Grade Girl'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '7th Grade Boy', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '7th Grade Boy'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '7th Grade Girl', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '7th Grade Girl'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '8th Grade Boy', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '8th Grade Boy'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '8th Grade Girl', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '8th Grade Girl'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'High School', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'High School'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '9th Grade Boy', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '9th Grade Boy'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '9th Grade Girl', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '9th Grade Girl'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '10th Grade Boy', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '10th Grade Boy'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '10th Grade Girl', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '10th Grade Girl'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '11th Grade Boy', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '11th Grade Boy'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '11th Grade Girl', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '11th Grade Girl'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '12th Grade Boy', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '12th Grade Boy'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, '12th Grade Girl', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '12th Grade Girl'

INSERT INTO [Group] ( [IsSystem],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, GT.Id, 'KidSpring', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'KidSpring'
SET @TopLevelGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @TopLevelGroupId, GT.Id, 'Nursery', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Nursery'
SET @ParentGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Cuddlers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Cuddlers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 1', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 1'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 2', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 2'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Crawlers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Crawlers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 3', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 3'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 4', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 4'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Walkers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Walkers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 5', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 5'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 6', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 6'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Toddlers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Toddlers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 7', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 7'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 8', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 8'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @TopLevelGroupId, GT.Id, 'Preschool', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Preschool'
SET @ParentGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, '2''s', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '2''s'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Fire Station', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Fire Station'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Lil'' Spring', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Lil'' Spring'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Pop''s Garage', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Pop''s Garage'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, '3''s', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '3''s'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Spring Fresh', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Spring Fresh'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'SpringTown Police', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'SpringTown Police'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'SpringTown Toys', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'SpringTown Toys'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, '4''s', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = '4''s'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Treehouse', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Treehouse'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Base Camp (PS)', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Base Camp (PS)'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Base Camp Jr.', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Base Camp Jr.'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @TopLevelGroupId, GT.Id, 'Elementary', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Elementary'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Base Camp (ES)', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Base Camp (ES)'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'ImagiNation - K', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'ImagiNation - K'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'ImagiNation - 1st', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'ImagiNation - 1st'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Jump Street - 2nd', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Jump Street - 2nd'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Jump Street - 3rd', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Jump Street - 3rd'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Shockwave - 4th', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Shockwave - 4th'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Shockwave - 5th', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Shockwave - 5th'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @TopLevelGroupId, GT.Id, 'Special Needs', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Special Needs'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Spring Zone', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Spring Zone'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Spring Zone Jr.', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Spring Zone Jr.'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @TopLevelGroupId, GT.Id, 'KidSpring Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'KidSpring Volunteers'
SET @ParentGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Elementary Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Elementary Volunteers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Base Camp (ES) Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Base Camp (ES) Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Elementary Service Leader', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Elementary Service Leader'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'ImagiNation Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'ImagiNation Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Jump Street Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Jump Street Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Shockwave Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Shockwave Volunteer'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Nursery Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Nursery Volunteers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Nursery Early Bird Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Nursery Early Bird Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Nursery Service Leader', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Nursery Service Leader'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 1 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 1 Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 2 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 2 Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 3 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 3 Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 4 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 4 Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 5 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 5 Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 6 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 6 Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 7 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 7 Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Wonder Way 8 Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Wonder Way 8 Volunteer'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Preschool Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Preschool Volunteers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Base Camp Jr. Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Base Camp Jr. Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Fire Station Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Fire Station Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Lil'' Spring Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Lil'' Spring Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Pop''s Garage Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Pop''s Garage Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Preschool Early Bird Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Preschool Early Bird Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Preschool Service Leader', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Preschool Service Leader'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Spring Fresh Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Spring Fresh Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'SpringTown Police Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'SpringTown Police Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'SpringTown Toys Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'SpringTown Toys Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Treehouse Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Treehouse Volunteer'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Guest Services', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Guest Services'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Advocate', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Advocate'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Character Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Character Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Check-In Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Check-In Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'First Time Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'First Time Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Guest Services Service Leader', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Guest Services Service Leader'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'KidSpring Greeter', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'KidSpring Greeter'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Production Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Production Volunteers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Elementary Production', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Elementary Production'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Preschool Production', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Preschool Production'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Special Needs Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Special Needs Volunteers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Spring Zone Jr. Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Spring Zone Jr. Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Spring Zone Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Spring Zone Volunteer'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Support Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Support Volunteers'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'KidSpring Office Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'KidSpring Office Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'KidSpring Trainee', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'KidSpring Trainee'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Sunday Support Volunteer', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Sunday Support Volunteer'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Volunteer Plug-In Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Volunteer Plug-In Team'

INSERT INTO [Group] ( [IsSystem],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, GT.Id, 'Volunteers', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Volunteers'
SET @ParentGroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Campus Support', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Campus Support'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Community Outreach', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Community Outreach'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Care & Outreach', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Care & Outreach'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Baptism Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Baptism Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Prayer Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Prayer Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Sunday Care Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Sunday Care Team'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Creative & Technology', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Creative & Technology'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Band Green Room', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Band Green Room'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'IT Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'IT Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Production Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Production Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Stories Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Stories Team'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Finance', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Finance'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Finance Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Finance Team'

INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @ParentGroupId, GT.Id, 'Guest Services', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Guest Services'
SET @GroupId = SCOPE_IDENTITY()
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Awake Coffee Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Awake Coffee Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Campus Safety', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Campus Safety'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Equipping Tour', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Equipping Tour'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Facility Cleaning Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Facility Cleaning Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Fuse Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Fuse Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Green Room', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Green Room'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Greeting Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Greeting Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Guest Service Desk Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Guest Service Desk Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Lobby Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Lobby Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Parking Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Parking Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Resource Center Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Resource Center Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Usher Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Usher Team'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Volunteer Coordinator', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Volunteer Coordinator'
INSERT INTO [Group] ( [IsSystem],[ParentGroupId],[GroupTypeId],[Name],[IsSecurityRole],[IsActive],[Guid]) 
SELECT 0, @GroupId, GT.Id, 'Volunteer Headquarters Team', 0, 1, NEWID() FROM [GroupType] GT WHERE GT.Name = 'Volunteer Headquarters Team'

------------------------------------------------------------------------
-- Create Schedules
------------------------------------------------------------------------
DELETE [Schedule]
INSERT INTO [Schedule] ([Name],[iCalendarContent],[CheckInStartOffsetMinutes],[CheckInEndOffsetMinutes],[EffectiveStartDate],[Guid]) VALUES 
    ('9:15 AM',
'BEGIN:VCALENDAR
BEGIN:VEVENT
DTEND:20130701T235900
DTSTART:20130625T000000
RRULE:FREQ=DAILY
END:VEVENT
END:VCALENDAR', '0', '1439', '06/01/2013', NEWID() )
INSERT INTO [Schedule] ([Name],[iCalendarContent], [CheckInStartOffsetMinutes],[CheckInEndOffsetMinutes],[EffectiveStartDate],[Guid]) VALUES 
    ('11:15 AM', 
'BEGIN:VCALENDAR
BEGIN:VEVENT
DTEND:20130701T235900
DTSTART:20130625T000000
RRULE:FREQ=DAILY
END:VEVENT
END:VCALENDAR', '0', '1439', '06/01/2013', NEWID() )
INSERT INTO [Schedule] ([Name],[iCalendarContent], [CheckInStartOffsetMinutes],[CheckInEndOffsetMinutes],[EffectiveStartDate],[Guid]) VALUES 
    ('4:00 PM', 
'BEGIN:VCALENDAR
BEGIN:VEVENT
DTEND:20130701T235900
DTSTART:20130625T000000
RRULE:FREQ=DAILY
END:VEVENT
END:VCALENDAR', '0', '1439', '06/01/2013', NEWID() )
INSERT INTO [Schedule] ([Name],[iCalendarContent], [CheckInStartOffsetMinutes],[CheckInEndOffsetMinutes],[EffectiveStartDate],[Guid]) VALUES 
    ('6:00 PM', 
'BEGIN:VCALENDAR
BEGIN:VEVENT
DTEND:20130701T235900
DTSTART:20130625T000000
RRULE:FREQ=DAILY
END:VEVENT
END:VCALENDAR', '0', '1439', '06/01/2013', NEWID() )

------------------------------------------------------------------------
-- Create Locations
------------------------------------------------------------------------
DELETE [Location]
DECLARE @CampusLocationId int
DECLARE @KioskLocationId int
DECLARE @RoomLocationId int

-- Anderson Locations
INSERT INTO [Location] ([Guid], [Name], [IsActive])	VALUES (NEWID(), 'Anderson', 1)
SET @CampusLocationId = SCOPE_IDENTITY()
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid])	VALUES (@CampusLocationId, 'Creativity', 1, NEWID())
SET @KioskLocationId = SCOPE_IDENTITY()
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Photo', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Storytelling', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Band Green Room', 1, NEWID())

INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid])	VALUES (@CampusLocationId, 'Discipleship', 1, NEWID())
SET @KioskLocationId = SCOPE_IDENTITY()
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Baptism Attendee', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Volunteer', 1, NEWID())

INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid])	VALUES (@CampusLocationId, 'Fuse', 1, NEWID())
SET @KioskLocationId = SCOPE_IDENTITY()
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '6th Grade Boy', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '6th Grade Girl', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '7th Grade Boy', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '7th Grade Girl', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '8th Grade Boy', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '8th Grade Girl', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '9th Grade Boy', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '9th Grade Girl', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '10th Grade Boy', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '10th Grade Girl', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '11th Grade Boy', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '11th Grade Girl', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '12th Grade Boy', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, '12th Grade Girl', 1, NEWID())

INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid])	VALUES (@CampusLocationId, 'KidSpring', 1, NEWID())
SET @KioskLocationId = SCOPE_IDENTITY()
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 1', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 2', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 3', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 4', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 5', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 6', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 7', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 8', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Fire Station', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Lil'' Spring', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Pop''s Garage', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Spring Fresh', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'SpringTown Police', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'SpringTown Toys', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Treehouse', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Base Camp Jr.', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Base Camp (ES)', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'ImagiNation - K', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'ImagiNation - 1st', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Jump Street - 2nd', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Jump Street - 3rd', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Shockwave - 4th', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Shockwave - 5th', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Spring Zone', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Spring Zone Jr.', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Base Camp (ES) Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Elementary Service Leader', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'ImagiNation Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Jump Street Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Shockwave Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Nursery Early Bird Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Nursery Service Leader', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 1 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 2 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 3 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 4 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 5 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 6 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 7 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Wonder Way 8 Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Base Camp Jr. Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Fire Station Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Lil'' Spring Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Pop''s Garage Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Preschool Early Bird Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Preschool Service Leader', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Spring Fresh Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'SpringTown Police Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'SpringTown Toys Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Treehouse Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Advocate', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Character Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Check-In Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'First Time Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Guest Services Service Leader', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'KidSpring Greeter', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Elementary Production', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Preschool Production', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Spring Zone Jr. Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Spring Zone Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'KidSpring Office Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'KidSpring Trainee', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Sunday Support Volunteer', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Volunteer Plug-In Team', 1, NEWID())

INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid])	VALUES (@CampusLocationId, 'Volunteers', 1, NEWID())
SET @KioskLocationId = SCOPE_IDENTITY()
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Community Outreach', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Baptism Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Prayer Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Sunday Care Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Band Green Room', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'IT Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Production Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Stories Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Finance Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Awake Coffee Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Campus Safety', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Equipping Tour', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Facility Cleaning Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Fuse Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Green Room', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Greeting Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Guest Service Desk Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Lobby Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Parking Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Resource Center Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Usher Team', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Volunteer Coordinator', 1, NEWID())
INSERT INTO [Location] ([ParentLocationId], [Name], [IsActive], [Guid]) VALUES (@KioskLocationId, 'Volunteer Headquarters Team', 1, NEWID())

------------------------------------------------------------------------
-- Devices (Kiosks)
------------------------------------------------------------------------
DELETE [DeviceLocation]
DELETE [Device]

DECLARE @fieldTypeIdText int = (select Id from FieldType where Guid = '9C204CD0-1233-41C5-818A-C5DA439445AA')

-- Device Types

DECLARE @DeviceTypeValueId int
SET @DeviceTypeValueId = (SELECT [Id] FROM [DefinedValue] WHERE [Guid] = 'BC809626-1389-4543-B8BB-6FAC79C27AFD')
DECLARE @PrinterTypevalueId int
SET @PrinterTypevalueId = (SELECT [Id] FROM [DefinedValue] WHERE [Guid] = '8284B128-E73B-4863-9FC2-43E6827B65E6')

DECLARE @PrinterDeviceId int
INSERT INTO [Device] ([Name],[DeviceTypeValueId],[IPAddress],[PrintFrom],[PrintToOverride],[Guid])
VALUES ('Test Label Printer',@PrinterTypevalueId, '10.1.20.200',0,1,NEWID())
SET @PrinterDeviceId = SCOPE_IDENTITY()

INSERT INTO [Device] ([Name],[DeviceTypeValueId],[PrinterDeviceId],[PrintFrom],[PrintToOverride],[Guid])
SELECT C.Name + ':' + B.Name + ':' + R.Name, @DeviceTypeValueId, @PrinterDeviceId, 0, 1, NEWID()
FROM Location C
INNER JOIN Location B
	ON B.ParentLocationId = C.Id
INNER JOIN Location R
	ON R.ParentLocationId = B.Id

INSERT INTO [DeviceLocation] (DeviceId, LocationId)
SELECT D.Id, R.Id
FROM Location C
INNER JOIN Location B
	ON B.ParentLocationId = C.Id
INNER JOIN Location R
	ON R.ParentLocationId = B.Id
INNER JOIN Device D 
	ON D.Name = C.Name + ':' + B.Name + ':' + R.Name

------------------------------------------------------------------------
-- Group Locations
------------------------------------------------------------------------
DELETE [GroupLocation]
INSERT INTO [GroupLocation] (GroupId, LocationId, Guid) 
SELECT G.Id, DL.LocationId, NEWID()
FROM DeviceLocation DL
INNER JOIN [Group] G ON G.Name IN ('Creativity', 'Discipleship', 'Fuse', 'KidSpring', 'Volunteers')

------------------------------------------------------------------------
-- Group Location Schedule
------------------------------------------------------------------------
DELETE [GroupLocationSchedule]

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Creativity'
INNER JOIN Schedule S ON S.[Name] = '9:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Creativity'
INNER JOIN Schedule S ON S.[Name] = '11:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Creativity'
INNER JOIN Schedule S ON S.[Name] = '4:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Creativity'
INNER JOIN Schedule S ON S.[Name] = '6:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Discipleship'
INNER JOIN Schedule S ON S.[Name] = '9:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Discipleship'
INNER JOIN Schedule S ON S.[Name] = '11:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Discipleship'
INNER JOIN Schedule S ON S.[Name] = '4:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Discipleship'
INNER JOIN Schedule S ON S.[Name] = '6:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Fuse'
INNER JOIN Schedule S ON S.[Name] = '9:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Fuse'
INNER JOIN Schedule S ON S.[Name] = '11:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Fuse'
INNER JOIN Schedule S ON S.[Name] = '4:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Fuse'
INNER JOIN Schedule S ON S.[Name] = '6:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'KidSpring'
INNER JOIN Schedule S ON S.[Name] = '9:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'KidSpring'
INNER JOIN Schedule S ON S.[Name] = '11:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'KidSpring'
INNER JOIN Schedule S ON S.[Name] = '4:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'KidSpring'
INNER JOIN Schedule S ON S.[Name] = '6:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Volunteers'
INNER JOIN Schedule S ON S.[Name] = '9:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Volunteers'
INNER JOIN Schedule S ON S.[Name] = '11:15 AM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Volunteers'
INNER JOIN Schedule S ON S.[Name] = '4:00 PM'

INSERT INTO [GroupLocationSchedule] (GroupLocationId, ScheduleId) 
SELECT GL.Id, S.Id
FROM GroupLocation GL
INNER JOIN [Group] G ON G.Id = GL.GroupId AND G.Name = 'Volunteers'
INNER JOIN Schedule S ON S.[Name] = '6:00 PM'


------------------------------------------------------------------------
-- Workflow Data
------------------------------------------------------------------------

-- Workflow Action Entity Types
IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.AttendedFindFamilies')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.AttendedFindFamilies', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.FilterActiveLocations')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.FilterActiveLocations', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.FilterByAge')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.FilterByAge', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.FindFamilies')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.FindFamilies', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.AttendedFindFamilyMembers')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.AttendedFindFamilyMembers', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.FindRelationships')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.FindRelationships', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.LoadGroups')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.LoadGroups', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.AttendedLoadGroupTypes')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.AttendedLoadGroupTypes', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.LoadLocations')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.LoadLocations', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.LoadSchedules')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.LoadSchedules', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.RemoveEmptyGroups')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.RemoveEmptyGroups', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.RemoveEmptyGroupTypes')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.RemoveEmptyGroupTypes', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.RemoveEmptyLocations')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.RemoveEmptyLocations', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.RemoveEmptyPeople')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.RemoveEmptyPeople', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.SaveAttendance')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.SaveAttendance', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.CreateLabels')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.CreateLabels', NEWID(), 0, 0)

IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.CalculateLastAttended')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Workflow.Action.CheckIn.CalculateLastAttended', NEWID(), 0, 0)

-- Workflow Entity Type
IF NOT EXISTS(SELECT Id FROM EntityType WHERE Name = 'Rock.Model.Workflow')
INSERT INTO EntityType (Name, Guid, IsEntity, IsSecured)
VALUES ('Rock.Model.Workflow', NEWID(), 0, 0)
DECLARE @WorkflowEntityTypeId int
SET @WorkflowEntityTypeId = (SELECT Id FROM EntityType WHERE Name = 'Rock.Model.Workflow')

/* ---------------------------------------------------------------------- */
------------------------------ END TEST DATA ---------------------------------
/* ---------------------------------------------------------------------- */

-- WorkflowActionType

-- Family Search
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity1, 'Find Families', 0, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.AttendedFindFamilies'

-- Person Search
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity2, 'Find Family Members', 0, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.AttendedFindFamilyMembers'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity2, 'Find Relationships', 1, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.FindRelationships'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity2, 'Load Group Types', 2, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.AttendedLoadGroupTypes'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity2, 'Filter by Age', 3, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.FilterByAge'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity2, 'Remove Empty People', 4, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.RemoveEmptyPeople'


-- Activity
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity3, 'Load Groups', 0, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.LoadGroups'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity3, 'Load Schedules', 0, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.LoadSchedules'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity3, 'Load Locations', 0, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.LoadLocations'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity3, 'Filter Active Locations', 1, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.FilterActiveLocations'


-- Confirm 
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity4, 'Save Attendance', 0, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.SaveAttendance'
INSERT INTO [WorkflowActionType] (ActivityTypeId, Name, [Order], [EntityTypeId], IsActionCompletedOnSuccess, IsActivityCompletedOnSuccess, Guid)
SELECT @WorkflowActivity4, 'Create Labels', 0, Id, 1, 0, NEWID() FROM EntityType WHERE Name = 'Rock.Workflow.Action.CheckIn.CreateLabels'



-- Attended Checkin parameter
DECLARE @TextFieldTypeId int
SET @TextFieldTypeId = (SELECT Id FROM FieldType WHERE guid = '9C204CD0-1233-41C5-818A-C5DA439445AA')
DELETE [Attribute] WHERE [Guid] = '9D2BFE8A-41F3-4A02-B3CF-9193F0C8419E'
INSERT INTO [Attribute] ( IsSystem, FieldTypeId, EntityTypeId, EntityTypeQualifierColumn, EntityTypeQualifierValue, [Key], Name, [Order], IsGridColumn, IsMultiValue, IsRequired, Guid)
VALUES ( 0, @TextFieldTypeId, @WorkflowEntityTypeId, 'WorkflowTypeId', CAST(@WorkflowTypeId as varchar), 'CheckInState', 'Check In State', 0, 0, 0, 0, '9D2BFE8A-41F3-4A02-B3CF-9193F0C8419E')

