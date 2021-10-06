/*********************************************************
SeeSharp Ltd
sharpNode Schema Creation Script
Release: 1.1.9

Date: March 2002
Author: IAM

sharpNode by Ian Monnox is licensed under GNU General Public License v3.0. 

You may obtain a copy of the License at

	https://www.gnu.org/licenses/gpl-3.0.en.html


** DESCRIPTION **

The following database schema was created by Ian Monnox in March 2002, copyrighted to a limited company called Seesharp.
Seesharp was incorporated in Febuary 2002 and dissolved in 2004. The IPO transferred to the author.

The Trade Control schema in sqlnode is derived from this design.
The schema supports manufacturing supply, but lacks the financial control systems of its successor.

The accompanying .BAK file contains Database Diagrams that are informative.

It has never been implemented in a live environment. 

**********************************************************/
GO
CREATE TABLE [tb_alloaction_status](
	[allocation_status_code] [smallint] NOT NULL,
	[allocation_status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_alloaction_status] PRIMARY KEY CLUSTERED 
(
	[allocation_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_allocations](
	[component_id] [bigint] NOT NULL,
	[component_class_code] [smallint] NOT NULL,
	[allocation_namespace] [nvarchar](250) NOT NULL,
	[allocation_status_code] [smallint] NOT NULL,
	[chain_behaviour_code] [smallint] NOT NULL,
	[reciprocal] [bit] NOT NULL,
	[quantity_required] [float] NOT NULL,
	[quantity_issued] [float] NOT NULL,
	[planned_material_cost] [float] NULL,
	[planned_direct_cost] [float] NULL,
	[planned_set_cost] [float] NULL,
	[planned_direct_hours] [float] NULL,
	[planned_completion_date] [datetime] NULL,
	[priority_days] [int] NULL,
	[actual_material_cost] [float] NULL,
	[actual_direct_cost] [float] NULL,
	[actual_set_cost] [float] NULL,
	[actual_direct_hours] [float] NULL,
	[actual_completion_date] [datetime] NULL,
	[allocation_comments] [ntext] NULL,
 CONSTRAINT [PK_tb_allocations] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_allocations_behaviour](
	[chain_behaviour_code] [smallint] NOT NULL,
	[chain_behaviour] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_component_behaviour] PRIMARY KEY CLUSTERED 
(
	[chain_behaviour_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_assemblies](
	[component_id] [bigint] NOT NULL,
	[assembly_type_code] [smallint] NOT NULL,
	[key_assembly] [bit] NOT NULL,
	[calendar_namespace] [nvarchar](250) NULL,
	[number_of_instances] [smallint] NOT NULL,
	[number_of_shifts] [smallint] NOT NULL,
	[purchase_cost] [money] NOT NULL,
	[resale_cost] [money] NOT NULL,
	[purchase_date] [datetime] NOT NULL,
	[cash_code] [nvarchar](10) NOT NULL,
	[plant_register_code] [nvarchar](50) NULL,
 CONSTRAINT [PK_vw_RESOURCES] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_assemblies_legacy](
	[component_id] [bigint] NOT NULL,
	[cost_rates_set] [datetime] NULL,
	[utilization_percent] [float] NOT NULL,
	[prepare_cost_rate] [float] NOT NULL,
	[transform_cost_rate] [float] NOT NULL,
	[depreciation_percent] [real] NULL,
	[asset_value] [money] NULL,
 CONSTRAINT [PK_tb_assemblies_legacy] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_assembly_narratives](
	[component_id] [bigint] NOT NULL,
	[narrative_id] [bigint] IDENTITY(1,1) NOT NULL,
	[transform_narrative] [ntext] NOT NULL,
 CONSTRAINT [PK_vw_RESOURCE_NARRATIVES] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[narrative_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_assembly_types](
	[assembly_type_code] [smallint] NOT NULL,
	[assembly_type] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_assembly_types] PRIMARY KEY CLUSTERED 
(
	[assembly_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_calendar](
	[component_id] [bigint] NOT NULL,
	[generation_date] [datetime] NOT NULL,
	[number_of_days] [int] NOT NULL,
 CONSTRAINT [PK_tb_calendar] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_calendar_breaks](
	[component_id] [bigint] NOT NULL,
	[day_number] [int] NOT NULL,
	[start_break_time] [datetime] NOT NULL,
	[end_break_time] [datetime] NOT NULL,
	[creation_date] [datetime] NULL,
 CONSTRAINT [PK_tb_calendar_breaks] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[day_number] ASC,
	[start_break_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_calendar_days](
	[component_id] [bigint] NOT NULL,
	[day_number] [int] NOT NULL,
	[day_date] [datetime] NULL,
	[from_time] [datetime] NULL,
	[to_time] [datetime] NULL,
 CONSTRAINT [PK_tb_calendar_days] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[day_number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_calendar_exception_assignments](
	[component_id] [bigint] NOT NULL,
	[exception_id] [int] NOT NULL,
	[activate_exception] [bit] NOT NULL,
	[creation_date] [datetime] NULL,
 CONSTRAINT [PK_tb_calendar_exception_assignments] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[exception_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_calendar_exceptions](
	[exception_id] [int] NOT NULL,
	[exception_description] [nvarchar](50) NOT NULL,
	[start_exception_datetime] [datetime] NOT NULL,
	[end_exception_timetime] [datetime] NOT NULL,
	[creation_date] [datetime] NULL,
 CONSTRAINT [PK_tb_calendar_exceptions] PRIMARY KEY CLUSTERED 
(
	[exception_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_cash_codes](
	[cash_code] [nvarchar](10) NOT NULL,
	[cash_code_description] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_cash_codes] PRIMARY KEY CLUSTERED 
(
	[cash_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_component_aggregates](
	[component_id] [bigint] NOT NULL,
	[from_datetime] [nvarchar](20) NOT NULL,
	[to_datetime] [nvarchar](20) NOT NULL,
	[supply_inputs] [bigint] NOT NULL,
	[supply_outputs] [bigint] NOT NULL,
	[demand_inputs] [bigint] NOT NULL,
	[demand_outputs] [bigint] NOT NULL,
	[unplanned_inputs] [bigint] NOT NULL,
	[unplanned_outputs] [int] NOT NULL,
	[total_adjustments] [int] NOT NULL,
	[total_input_quantity_good] [float] NOT NULL,
	[total_input_quantity_bad] [float] NOT NULL,
	[total_output_quantity_good] [float] NOT NULL,
	[total_output_quantity_bad] [float] NOT NULL,
	[total_adjustment_quantity] [float] NOT NULL,
	[total_preparation_time] [float] NOT NULL,
	[total_transform_time] [float] NOT NULL,
	[total_input_value] [float] NOT NULL,
	[total_output_value] [float] NOT NULL,
 CONSTRAINT [PK_tb_concept_production_inout] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[from_datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_component_classes](
	[component_class_code] [smallint] NOT NULL,
	[component_class] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_component_classes] PRIMARY KEY CLUSTERED 
(
	[component_class_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_component_comms_id](
	[component_id] [bigint] NOT NULL,
	[comms_type_code] [smallint] NOT NULL,
	[comms_description] [nvarchar](50) NULL,
	[communication_id] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_component_communication_ids] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[comms_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_component_comms_types](
	[comms_type_code] [smallint] NOT NULL,
	[communication_type] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_tb_comminucation_types] PRIMARY KEY CLUSTERED 
(
	[comms_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_component_delivery](
	[component_id] [bigint] NOT NULL,
 CONSTRAINT [PK_tb_component_delivery] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_component_status](
	[component_status_code] [smallint] NOT NULL,
	[component_status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_component_status] PRIMARY KEY CLUSTERED 
(
	[component_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_component_types](
	[component_class_code] [smallint] NOT NULL,
	[component_type_code] [smallint] NOT NULL,
	[component_type] [nvarchar](50) NOT NULL,
	[profile_name] [nvarchar](50) NULL,
	[item_visible] [bit] NOT NULL,
	[namespace_prefix] [nvarchar](5) NULL,
	[next_id] [bigint] NOT NULL,
 CONSTRAINT [PK_tb_component_types] PRIMARY KEY CLUSTERED 
(
	[component_class_code] ASC,
	[component_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_components](
	[component_id] [bigint] IDENTITY(1000,1) NOT NULL,
	[component_class_code] [smallint] NOT NULL,
	[component_type_code] [smallint] NOT NULL,
	[full_namespace] [nvarchar](250) NOT NULL,
	[root_namespace] [nvarchar](200) NOT NULL,
	[component_name] [nvarchar](100) NOT NULL,
	[component_description] [nvarchar](100) NULL,
	[component_status_code] [smallint] NOT NULL,
	[component_text] [ntext] NULL,
	[creation_date] [datetime] NOT NULL,
	[modified_date] [datetime] NOT NULL,
 CONSTRAINT [IX_tb_component_full_namespace] UNIQUE CLUSTERED 
(
	[full_namespace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_concept](
	[component_id] [bigint] NOT NULL,
	[valid_from_date] [datetime] NOT NULL,
	[valid_to_date] [datetime] NOT NULL,
	[concept_group_code] [nvarchar](20) NULL,
	[concept_feature] [nvarchar](30) NULL,
	[concept_feature_id] [nvarchar](30) NULL,
	[tax_code] [nvarchar](10) NULL,
	[supply_type_code] [smallint] NOT NULL,
	[enforced_approvals] [bit] NOT NULL,
 CONSTRAINT [PK_tb_concept] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_approvals](
	[component_id] [bigint] NOT NULL,
	[approval_id] [bigint] IDENTITY(1,1) NOT NULL,
	[approval_rating] [smallint] NOT NULL,
	[external_namespace] [nvarchar](250) NOT NULL,
	[internal_namespace] [nvarchar](250) NOT NULL,
	[approval_notes] [ntext] NULL,
	[approval_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_concept_approvals] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[approval_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_concept_config](
	[component_id] [bigint] NOT NULL,
	[config_type_code] [smallint] NOT NULL,
	[digit_placement_holder] [smallint] NOT NULL,
	[enforced] [bit] NOT NULL,
	[config_criteria] [ntext] NULL,
 CONSTRAINT [PK_tb_concept_config] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_concept_config_types](
	[config_type_code] [smallint] NOT NULL,
	[config_type] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_concept_config_types] PRIMARY KEY CLUSTERED 
(
	[config_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_features](
	[concept_feature] [nvarchar](30) NOT NULL,
	[feature_description] [nvarchar](100) NULL,
 CONSTRAINT [PK_tb_concept_production_features] PRIMARY KEY CLUSTERED 
(
	[concept_feature] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_group_codes](
	[concept_group_code] [nvarchar](20) NOT NULL,
	[concept_group] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tb_concept_group_codes] PRIMARY KEY CLUSTERED 
(
	[concept_group_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_product_abc](
	[abc_code] [nvarchar](1) NOT NULL,
	[check_days] [smallint] NULL,
 CONSTRAINT [PK_tb_concept_production_abc] PRIMARY KEY CLUSTERED 
(
	[abc_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_product_dims](
	[component_id] [bigint] NOT NULL,
	[pack_weight] [int] NOT NULL,
	[pack_length] [int] NOT NULL,
	[pack_width] [int] NOT NULL,
	[pack_height] [int] NOT NULL,
	[quantity_per_pack] [int] NOT NULL,
	[quantity_per_pallet] [int] NOT NULL,
	[quantity_per_bag] [int] NOT NULL,
	[interleaves_per_pack] [smallint] NOT NULL,
	[bags_per_pack] [smallint] NOT NULL,
	[packs_high_per_pallet] [smallint] NOT NULL,
	[component_weight] [float] NOT NULL,
	[component_volume] [float] NOT NULL,
	[component_length] [int] NOT NULL,
	[component_width] [int] NOT NULL,
	[component_height] [int] NOT NULL,
 CONSTRAINT [PK_tb_concept_production_dims] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_product_legacy](
	[component_id] [bigint] NOT NULL,
	[std_cost_updated] [datetime] NULL,
	[std_unit_material_cost] [float] NOT NULL,
	[std_unit_prepare_cost] [float] NOT NULL,
	[std_unit_transform_cost] [float] NOT NULL,
	[actual_cost_updated] [datetime] NULL,
	[actual_unit_material_cost] [float] NOT NULL,
	[actual_unit_prepare_cost] [float] NOT NULL,
	[actual_unit_transform_cost] [float] NOT NULL,
 CONSTRAINT [PK_tb_concept_production_legacy] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_product_policies](
	[stock_policy_code] [smallint] NOT NULL,
	[stock_policy] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_concept_production_policies] PRIMARY KEY CLUSTERED 
(
	[stock_policy_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_product_price_lists](
	[component_id] [bigint] NOT NULL,
	[denomination] [nvarchar](5) NOT NULL,
	[price_start_datetime] [datetime] NOT NULL,
	[price_end_datetime] [datetime] NOT NULL,
	[upper_quantity] [float] NOT NULL,
	[unit_charge] [float] NOT NULL,
	[catalogue_number] [nvarchar](100) NULL,
	[creation_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_concept_production_pricelists] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[denomination] ASC,
	[price_start_datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_product_text](
	[component_id] [bigint] NOT NULL,
	[concept_drawing] [image] NULL,
	[production_output_text] [ntext] NULL,
	[production_input_text] [ntext] NULL,
	[concept_notes] [ntext] NULL,
 CONSTRAINT [PK_tb_concept_text] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_concept_products](
	[component_id] [bigint] NOT NULL,
	[location_namespace] [nvarchar](250) NOT NULL,
	[drawing_number] [nvarchar](20) NULL,
	[drawing_issue] [nvarchar](10) NULL,
	[external_unit_of_measure] [nvarchar](15) NOT NULL,
	[internal_unit_of_measure] [nvarchar](15) NOT NULL,
	[external_unit_charge] [float] NOT NULL,
	[internal_unit_cost] [float] NOT NULL,
	[stock_policy_code] [smallint] NOT NULL,
	[abc_code] [nvarchar](1) NULL,
	[on_hold] [bit] NOT NULL,
	[global_scrap_allowance] [float] NOT NULL,
	[minumum_stock_level] [int] NOT NULL,
	[order_multiple_quantity] [int] NOT NULL,
	[planning_window_days] [smallint] NOT NULL,
	[buffer_days] [smallint] NOT NULL,
	[standard_batch_size] [int] NOT NULL,
	[maximum_batch_size] [bit] NOT NULL,
	[plan_with_batch_size] [bit] NOT NULL,
	[plan_with_minimum_stock] [bit] NOT NULL,
	[packed_component] [bit] NOT NULL,
	[quantity_onhand] [float] NOT NULL,
	[last_stock_check] [datetime] NULL,
	[last_receipt_date] [datetime] NULL,
	[last_issue_date] [datetime] NULL,
 CONSTRAINT [PK_tb_concept_production] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_service](
	[component_id] [bigint] NOT NULL,
	[skill_class_code] [nvarchar](20) NOT NULL,
	[from_skill_level] [smallint] NOT NULL,
	[to_skill_level] [smallint] NOT NULL,
	[transformer_skill_level] [smallint] NOT NULL,
	[service_type_code] [smallint] NOT NULL,
	[external_unit_of_time] [smallint] NOT NULL,
	[internal_unit_of_time] [smallint] NOT NULL,
	[external_total_charge] [float] NOT NULL,
	[external_total_cost] [float] NOT NULL,
	[maximum_units] [int] NOT NULL,
	[maximum_time] [float] NOT NULL,
 CONSTRAINT [PK_tb_concept_service] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_service_time_rates](
	[component_id] [bigint] NOT NULL,
	[denomination] [nvarchar](5) NOT NULL,
	[price_start_datetime] [datetime] NOT NULL,
	[price_end_datetime] [datetime] NOT NULL,
	[rate_interval] [smallint] NOT NULL,
	[time_rate] [float] NOT NULL,
	[contract_number] [nvarchar](100) NULL,
	[creation_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_concept_service_time_rates] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[denomination] ASC,
	[price_start_datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_service_types](
	[service_type_code] [smallint] NOT NULL,
	[service_type] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_concept_service_types] PRIMARY KEY CLUSTERED 
(
	[service_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_concept_service_unit_rates](
	[component_id] [bigint] NOT NULL,
	[denomination] [nvarchar](5) NOT NULL,
	[price_start_datetime] [datetime] NOT NULL,
	[price_end_datetime] [datetime] NOT NULL,
	[unit_quantity] [float] NOT NULL,
	[unit_charge] [float] NOT NULL,
	[contract_number] [nvarchar](100) NULL,
	[creation_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_concept_service_contract] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[denomination] ASC,
	[price_start_datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_currencies](
	[denomination] [nvarchar](5) NOT NULL,
	[currency_name] [nvarchar](50) NOT NULL,
	[exchange_rate] [float] NOT NULL,
	[last_updated] [datetime] NULL,
	[creation_date] [datetime] NULL,
 CONSTRAINT [PK_tb_currencies] PRIMARY KEY CLUSTERED 
(
	[denomination] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_demand](
	[component_id] [bigint] NOT NULL,
	[full_namespace] [nvarchar](250) NOT NULL,
	[external_namespace] [nvarchar](250) NULL,
	[contact_namespace] [nvarchar](250) NULL,
	[controller_namespace] [nvarchar](250) NULL,
	[demand_status_code] [smallint] NOT NULL,
	[on_hold] [smallint] NOT NULL,
	[target_namespace] [nvarchar](250) NOT NULL,
	[total_charge] [float] NOT NULL,
	[denomination] [nvarchar](5) NOT NULL,
	[exchange_rate] [float] NOT NULL,
	[payment_status_code] [smallint] NOT NULL,
	[paid_charge] [float] NOT NULL,
	[paid_tax] [float] NOT NULL,
	[last_payment_date] [datetime] NULL,
	[first_payment_date] [datetime] NULL,
	[cash_code] [nvarchar](10) NOT NULL,
	[tax_code] [nvarchar](10) NOT NULL,
	[discount_percent] [real] NOT NULL,
	[discount_days] [smallint] NOT NULL,
	[settlement_percent] [float] NOT NULL,
	[demand_analysis_1] [nvarchar](10) NULL,
	[demand_analysis_2] [nvarchar](10) NULL,
	[demand_analysis_3] [nvarchar](10) NULL,
	[internal_notes] [ntext] NULL,
	[external_notes] [ntext] NULL,
 CONSTRAINT [PK_tb_demand] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_demand_containers](
	[component_id] [bigint] NOT NULL,
	[on_hold] [smallint] NOT NULL,
	[target_namespace] [nvarchar](250) NOT NULL,
	[external_namespace] [nvarchar](250) NULL,
	[contact_namespace] [nvarchar](250) NULL,
	[controller_namespace] [nvarchar](250) NULL,
	[total_charge] [float] NOT NULL,
	[denomination] [nvarchar](5) NOT NULL,
	[exchange_rate] [float] NOT NULL,
	[payment_status_code] [smallint] NOT NULL,
	[paid_charge] [float] NOT NULL,
	[paid_tax] [float] NOT NULL,
	[last_payment_date] [datetime] NULL,
	[first_payment_date] [datetime] NULL,
	[cash_code] [nvarchar](10) NOT NULL,
	[tax_code] [nvarchar](10) NOT NULL,
	[discount_percent] [real] NOT NULL,
	[discount_days] [smallint] NOT NULL,
	[settlement_percent] [float] NOT NULL,
	[demand_analysis_1] [nvarchar](10) NULL,
	[demand_analysis_2] [nvarchar](10) NULL,
	[demand_analysis_3] [nvarchar](10) NULL,
	[internal_notes] [ntext] NULL,
	[external_notes] [ntext] NULL,
	[creation_date] [datetime] NOT NULL,
	[modified_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_demand_containers] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_demand_products](
	[component_id] [bigint] NOT NULL,
	[quantity_ordered] [float] NOT NULL,
	[quantity_fulfilled] [float] NOT NULL,
	[unit_charge] [float] NOT NULL,
	[departure_date] [datetime] NOT NULL,
	[arrival_date] [datetime] NOT NULL,
	[traceable_environment] [bit] NOT NULL,
 CONSTRAINT [PK_tb_demand_goods] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_demand_services](
	[component_id] [bigint] NOT NULL,
	[recurrent_cycle] [bit] NOT NULL,
	[charge_day_of_month] [smallint] NOT NULL,
 CONSTRAINT [PK_tb_demand_services] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_demand_status](
	[demand_status_code] [smallint] NOT NULL,
	[demand_status] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_tb_demand_status] PRIMARY KEY CLUSTERED 
(
	[demand_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_event_actions](
	[event_action_code] [smallint] NOT NULL,
	[event_action] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_event_names] PRIMARY KEY CLUSTERED 
(
	[event_action_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_event_log](
	[component_id] [bigint] NOT NULL,
	[event_id] [bigint] NOT NULL,
	[transaction_id] [bigint] IDENTITY(1,1) NOT NULL,
	[log_date] [datetime] NOT NULL,
	[event_status_code] [smallint] NOT NULL,
	[controller_namespace] [nvarchar](250) NOT NULL,
	[unit_time] [float] NOT NULL,
	[total_time] [float] NOT NULL,
	[quantity_good] [float] NOT NULL,
	[quantity_bad] [float] NOT NULL,
	[log_notes] [ntext] NULL,
 CONSTRAINT [PK_tb_event_log] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[event_id] ASC,
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_event_processes](
	[component_id] [bigint] NOT NULL,
	[event_id] [bigint] NOT NULL,
	[source_namespace] [nvarchar](250) NOT NULL,
	[quantity] [float] NOT NULL,
	[planned_start_date] [datetime] NOT NULL,
	[planned_finish_date] [datetime] NOT NULL,
	[actual_start_date] [datetime] NULL,
	[actual_finish_date] [datetime] NULL,
	[total_throughput_value] [money] NOT NULL,
 CONSTRAINT [PK_tb_event_processes] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[event_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_event_responses](
	[component_id] [bigint] NOT NULL,
	[event_id] [bigint] NOT NULL,
	[event_data] [ntext] NOT NULL,
	[receive_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_event_responses] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[event_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_event_status](
	[event_status_code] [smallint] NOT NULL,
	[event_status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_event_status] PRIMARY KEY CLUSTERED 
(
	[event_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_event_triggers](
	[component_id] [bigint] NOT NULL,
	[event_id] [bigint] NOT NULL,
	[event_criteria] [ntext] NOT NULL,
	[event_data] [ntext] NOT NULL,
	[last_send_date] [datetime] NOT NULL,
	[last_receive_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_event_triggers] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[event_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_event_types](
	[event_type_code] [smallint] NOT NULL,
	[event_type] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_event_types] PRIMARY KEY CLUSTERED 
(
	[event_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_events](
	[component_id] [bigint] NOT NULL,
	[event_id] [bigint] IDENTITY(1,1) NOT NULL,
	[event_type_code] [smallint] NOT NULL,
	[event_action_code] [smallint] NOT NULL,
	[event_status_code] [smallint] NOT NULL,
	[controller_namespace] [nvarchar](250) NOT NULL,
	[target_namespace] [nvarchar](250) NOT NULL,
	[event_notes] [ntext] NULL,
 CONSTRAINT [PK_tb_events] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[event_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_organisation_area_codes](
	[area_code] [nvarchar](10) NOT NULL,
	[area_description] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_organisation_area_codes] PRIMARY KEY CLUSTERED 
(
	[area_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_organisation_categories](
	[organisation_category_code] [smallint] NOT NULL,
	[organisation_category] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_organisation_categories] PRIMARY KEY CLUSTERED 
(
	[organisation_category_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_organisation_hold_status](
	[hold_status_code] [smallint] NOT NULL,
	[hold_status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_organisation_status_codes] PRIMARY KEY CLUSTERED 
(
	[hold_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_organisation_sector_codes](
	[sector_code] [nvarchar](10) NOT NULL,
	[sector_description] [nvarchar](50) NULL,
 CONSTRAINT [PK_tb_organisation_sector_codes] PRIMARY KEY CLUSTERED 
(
	[sector_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_organisation_sources](
	[organisation_source_id] [int] NOT NULL,
	[organisation_source] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tb_organisation_sources] PRIMARY KEY CLUSTERED 
(
	[organisation_source_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_organisation_status](
	[organisation_status_code] [smallint] NOT NULL,
	[organisation_status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_organisation_status] PRIMARY KEY CLUSTERED 
(
	[organisation_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_organisations](
	[component_id] [bigint] NOT NULL,
	[organisation_category_code] [smallint] NOT NULL,
	[hold_status_code] [smallint] NOT NULL,
	[organisation_status_code] [smallint] NOT NULL,
	[organisation_source_id] [int] NULL,
	[full_address] [ntext] NOT NULL,
	[unit_address] [nvarchar](50) NULL,
	[road_address] [nvarchar](50) NULL,
	[town_city] [nvarchar](50) NULL,
	[county_state] [nvarchar](50) NULL,
	[post_code] [nvarchar](20) NULL,
	[web_site] [nvarchar](100) NULL,
	[tax_code] [nvarchar](10) NOT NULL,
	[sector_code] [nvarchar](10) NULL,
	[area_code] [nvarchar](10) NULL,
	[cash_code] [nvarchar](10) NOT NULL,
	[discount_percent] [real] NOT NULL,
	[denomination] [nvarchar](5) NULL,
	[discount_days] [smallint] NOT NULL,
	[settlement_percent] [float] NOT NULL,
	[telephone_number] [nvarchar](50) NULL,
	[fax_number] [nvarchar](50) NULL,
	[email_address] [nvarchar](100) NULL,
	[number_of_employees] [int] NOT NULL,
	[turnover_per_anum] [float] NOT NULL,
	[business_description] [ntext] NULL,
	[certificate_of_conformity] [bit] NULL,
	[analysis_code_1] [nvarchar](10) NULL,
	[analysis_code_2] [nvarchar](10) NULL,
	[analysis_code_3] [nvarchar](10) NULL,
	[default_delivery_text] [ntext] NULL,
	[default_invoice_text] [ntext] NULL,
 CONSTRAINT [PK_tb_organisations] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_payment_status](
	[payment_status_code] [smallint] NOT NULL,
	[payment_status] [nvarchar](25) NOT NULL,
 CONSTRAINT [PK_tb_payment_status] PRIMARY KEY CLUSTERED 
(
	[payment_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_people](
	[component_id] [bigint] NOT NULL,
	[title] [nvarchar](10) NULL,
	[calendar_namespace] [nvarchar](250) NULL,
	[home_address] [ntext] NULL,
	[nick_name] [nvarchar](20) NULL,
	[job_title] [nvarchar](50) NULL,
	[profession] [nvarchar](50) NULL,
	[department] [nvarchar](50) NULL,
	[telephone_number] [nvarchar](50) NULL,
	[fax_number] [nvarchar](50) NULL,
	[email_address] [nvarchar](100) NULL,
 CONSTRAINT [PK_tb_people] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_people_role_types](
	[role_code] [smallint] NOT NULL,
	[role_description] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_people_role_types] PRIMARY KEY CLUSTERED 
(
	[role_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_people_roles](
	[component_id] [bigint] NOT NULL,
	[role_code] [smallint] NOT NULL,
	[role_notes] [nvarchar](50) NULL,
	[creation_date] [datetime] NULL,
 CONSTRAINT [PK_tb_people_roles] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[role_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_people_skills](
	[component_id] [bigint] NOT NULL,
	[skill_class_code] [nvarchar](20) NOT NULL,
	[skill_level] [smallint] NOT NULL,
	[skill_notes] [nvarchar](50) NULL,
	[source_namespace] [nvarchar](250) NULL,
	[creation_date] [datetime] NOT NULL,
 CONSTRAINT [PK_tb_people_skills] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC,
	[skill_class_code] ASC,
	[skill_level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_people_titles](
	[title] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_tb_people_titles] PRIMARY KEY CLUSTERED 
(
	[title] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_resource_simulations](
	[component_id] [bigint] NOT NULL,
	[simulation_date] [datetime] NOT NULL,
	[simulation_successful] [bit] NOT NULL,
	[simulation_description] [nvarchar](50) NULL,
	[full_namespace] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_tb_simulations] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_resource_skill_classes](
	[skill_class_code] [nvarchar](20) NOT NULL,
	[skill_class_description] [nvarchar](50) NOT NULL,
	[skill_class_notes] [ntext] NULL,
 CONSTRAINT [PK_tb_people_membership] PRIMARY KEY CLUSTERED 
(
	[skill_class_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_resource_skill_levels](
	[skill_class_code] [nvarchar](20) NOT NULL,
	[skill_level] [smallint] NOT NULL,
	[skill_level_description] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_tb_skill_levels] PRIMARY KEY CLUSTERED 
(
	[skill_class_code] ASC,
	[skill_level] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_supply](
	[component_id] [bigint] NOT NULL,
	[supply_type_code] [smallint] NOT NULL,
	[supply_status_code] [smallint] NOT NULL,
	[supply_cost_status_code] [smallint] NOT NULL,
	[controller_namespace] [nvarchar](250) NOT NULL,
	[location_namespace] [nvarchar](250) NOT NULL,
	[unit_throughput_value] [float] NOT NULL,
	[unit_input_value] [float] NOT NULL,
	[total_throughput_value] [float] NOT NULL,
	[total_input_value] [float] NOT NULL,
	[planned_material_cost] [float] NOT NULL,
	[planned_direct_cost] [float] NOT NULL,
	[planned_set_cost] [float] NOT NULL,
	[planned_direct_hours] [float] NOT NULL,
	[planned_completion_date] [datetime] NOT NULL,
	[priority_days] [int] NOT NULL,
	[actual_material_cost] [float] NOT NULL,
	[actual_direct_cost] [float] NOT NULL,
	[actual_set_cost] [float] NOT NULL,
	[actual_direct_hours] [float] NOT NULL,
	[actual_completion_date] [datetime] NULL,
	[supply_comments] [ntext] NULL,
	[first_event_date] [datetime] NULL,
	[last_event_date] [datetime] NULL,
	[last_transform_namespace] [nvarchar](50) NULL,
	[quantity_planned] [float] NOT NULL,
	[quantity_received] [float] NOT NULL,
	[quantity_issued] [float] NOT NULL,
	[quantity_onhand] [float] NOT NULL,
	[last_stock_check] [datetime] NULL,
	[last_issue_date] [datetime] NULL,
	[quantity_good_so_far] [float] NOT NULL,
	[quantity_bad_so_far] [float] NOT NULL,
 CONSTRAINT [PK_tb_supply] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
CREATE TABLE [tb_supply_products](
	[component_id] [bigint] NOT NULL,
	[quantity_planned] [float] NOT NULL,
	[quantity_received] [float] NOT NULL,
	[quantity_issued] [float] NOT NULL,
	[quantity_onhand] [float] NOT NULL,
	[last_stock_check] [datetime] NULL,
	[last_issue_date] [datetime] NULL,
	[quantity_good_so_far] [float] NOT NULL,
	[quantity_bad_so_far] [float] NOT NULL,
 CONSTRAINT [PK_tb_supply_products] PRIMARY KEY CLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_supply_status](
	[supply_status_code] [smallint] NOT NULL,
	[supply_status] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tb_supply_status] PRIMARY KEY CLUSTERED 
(
	[supply_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_supply_types](
	[supply_type_code] [smallint] NOT NULL,
	[supply_type] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_tb_supply_types] PRIMARY KEY CLUSTERED 
(
	[supply_type_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_tax_rates](
	[tax_code] [nvarchar](10) NOT NULL,
	[tax_rate] [float] NOT NULL,
 CONSTRAINT [PK_tb_tax_rates] PRIMARY KEY CLUSTERED 
(
	[tax_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_units_of_measure](
	[unit_of_measure] [nvarchar](15) NOT NULL,
	[decimal_precision] [smallint] NOT NULL,
 CONSTRAINT [PK_tb_units_of_measure] PRIMARY KEY CLUSTERED 
(
	[unit_of_measure] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_units_of_time](
	[unit_of_time] [smallint] NOT NULL,
	[time_bucket] [nvarchar](20) NOT NULL,
	[decimal_precision] [smallint] NOT NULL,
 CONSTRAINT [PK_tb_units_of_time] PRIMARY KEY CLUSTERED 
(
	[unit_of_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_uom_conversions](
	[external_unit_of_measure] [nvarchar](15) NOT NULL,
	[internal_unit_of_measure] [nvarchar](15) NOT NULL,
	[conversion_quantity] [int] NOT NULL,
 CONSTRAINT [PK_tb_uom_conversions] PRIMARY KEY CLUSTERED 
(
	[external_unit_of_measure] ASC,
	[internal_unit_of_measure] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [tb_uot_conversions](
	[external_unit_of_time] [smallint] NOT NULL,
	[internal_unit_of_time] [smallint] NOT NULL,
	[conversion_quantity] [int] NOT NULL,
 CONSTRAINT [PK_tb_uot_conversions] PRIMARY KEY CLUSTERED 
(
	[external_unit_of_time] ASC,
	[internal_unit_of_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [tb_component_types] ADD  CONSTRAINT [IX_tb_component_types_profile] UNIQUE NONCLUSTERED 
(
	[profile_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tb_component_types] ON [tb_component_types]
(
	[component_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [tb_components] ADD  CONSTRAINT [PK_tb_component] PRIMARY KEY NONCLUSTERED 
(
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tb_components_class] ON [tb_components]
(
	[component_class_code] ASC,
	[component_type_code] ASC,
	[component_status_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tb_components_name] ON [tb_components]
(
	[component_name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tb_components_root] ON [tb_components]
(
	[root_namespace] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_tb_concept_approvals_rating] ON [tb_concept_approvals]
(
	[component_id] ASC,
	[approval_rating] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [IX_tb_concept_production_location] UNIQUE NONCLUSTERED 
(
	[location_namespace] ASC,
	[component_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_component_chain_chain_type_code]  DEFAULT (1) FOR [component_class_code]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_allocation_status_code]  DEFAULT (1) FOR [allocation_status_code]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_component_chain_chain_behaviour_code]  DEFAULT (1) FOR [chain_behaviour_code]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_component_chain_reciprocal]  DEFAULT (0) FOR [reciprocal]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_component_chain_Quantity]  DEFAULT (1) FOR [quantity_required]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_quantity_issued]  DEFAULT (0) FOR [quantity_issued]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_planned_material_cost]  DEFAULT (0) FOR [planned_material_cost]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_planned_direct_cost]  DEFAULT (0) FOR [planned_direct_cost]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_planned_set_cost]  DEFAULT (0) FOR [planned_set_cost]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_planned_direct_hours]  DEFAULT (0) FOR [planned_direct_hours]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_priority_days]  DEFAULT (0) FOR [priority_days]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_actual_material_cost]  DEFAULT (0) FOR [actual_material_cost]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_actual_direct_cost]  DEFAULT (0) FOR [actual_direct_cost]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_actual_set_cost]  DEFAULT (0) FOR [actual_set_cost]
GO
ALTER TABLE [tb_allocations] ADD  CONSTRAINT [DF_tb_allocations_actual_direct_hours]  DEFAULT (0) FOR [actual_direct_hours]
GO
ALTER TABLE [tb_allocations_behaviour] ADD  CONSTRAINT [DF_tb_component_behaviour_chain_behaviour_code]  DEFAULT (1) FOR [chain_behaviour_code]
GO
ALTER TABLE [tb_assemblies] ADD  CONSTRAINT [DF_tb_assemblies_assembly_type_code]  DEFAULT (1) FOR [assembly_type_code]
GO
ALTER TABLE [tb_assemblies] ADD  CONSTRAINT [DF_tb_assemblies_purchase_cost]  DEFAULT (0) FOR [purchase_cost]
GO
ALTER TABLE [tb_assemblies] ADD  CONSTRAINT [DF_tb_assemblies_resale_cost]  DEFAULT (0) FOR [resale_cost]
GO
ALTER TABLE [tb_assemblies] ADD  CONSTRAINT [DF_tb_assemblies_purchase_date]  DEFAULT (getdate()) FOR [purchase_date]
GO
ALTER TABLE [tb_assemblies_legacy] ADD  CONSTRAINT [DF_tb_assemblies_legacy_utilization_percent]  DEFAULT (1) FOR [utilization_percent]
GO
ALTER TABLE [tb_assemblies_legacy] ADD  CONSTRAINT [DF_tb_assemblies_legacy_prepare_cost_rate_1]  DEFAULT (0) FOR [prepare_cost_rate]
GO
ALTER TABLE [tb_assemblies_legacy] ADD  CONSTRAINT [DF_tb_assemblies_legacy_transform_cost_rate_1]  DEFAULT (0) FOR [transform_cost_rate]
GO
ALTER TABLE [tb_assemblies_legacy] ADD  CONSTRAINT [DF_tb_assemblies_legacy_depreciation_percent]  DEFAULT (0.2) FOR [depreciation_percent]
GO
ALTER TABLE [tb_calendar] ADD  CONSTRAINT [DF_tb_calendar_calendar_id]  DEFAULT (1) FOR [component_id]
GO
ALTER TABLE [tb_calendar] ADD  CONSTRAINT [DF_tb_calendar_generation_date]  DEFAULT (getdate()) FOR [generation_date]
GO
ALTER TABLE [tb_calendar] ADD  CONSTRAINT [DF_tb_calendar_number_of_days]  DEFAULT (7) FOR [number_of_days]
GO
ALTER TABLE [tb_calendar_breaks] ADD  CONSTRAINT [DF_tb_calendar_breaks_calendar_id]  DEFAULT (1) FOR [component_id]
GO
ALTER TABLE [tb_calendar_breaks] ADD  CONSTRAINT [DF_tb_calendar_breaks_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_calendar_days] ADD  CONSTRAINT [DF_tb_calendar_days_calendar_id]  DEFAULT (1) FOR [component_id]
GO
ALTER TABLE [tb_calendar_exception_assignments] ADD  CONSTRAINT [DF_tb_calendar_exception_assignments_calendar_id]  DEFAULT (1) FOR [component_id]
GO
ALTER TABLE [tb_calendar_exception_assignments] ADD  CONSTRAINT [DF_tb_calendar_exception_assignments_exception_id]  DEFAULT (1) FOR [exception_id]
GO
ALTER TABLE [tb_calendar_exception_assignments] ADD  CONSTRAINT [DF_tb_calendar_exception_assignments_activate_exception]  DEFAULT (1) FOR [activate_exception]
GO
ALTER TABLE [tb_calendar_exception_assignments] ADD  CONSTRAINT [DF_tb_calendar_exception_assignments_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_calendar_exceptions] ADD  CONSTRAINT [DF_tb_calendar_exceptions_exception_id]  DEFAULT (1) FOR [exception_id]
GO
ALTER TABLE [tb_calendar_exceptions] ADD  CONSTRAINT [DF_tb_calendar_exceptions_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_supply_receipts]  DEFAULT (0) FOR [supply_inputs]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_supply_issues]  DEFAULT (0) FOR [supply_outputs]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_demand_issues]  DEFAULT (0) FOR [demand_inputs]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_demand_receipts]  DEFAULT (0) FOR [demand_outputs]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_unplanned_receipts]  DEFAULT (0) FOR [unplanned_inputs]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_unplanned_issues]  DEFAULT (0) FOR [unplanned_outputs]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_stock_adjustments]  DEFAULT (0) FOR [total_adjustments]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_total_receipt_quantity]  DEFAULT (0) FOR [total_input_quantity_good]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_component_aggregates_total_input_quantity_good1]  DEFAULT (0) FOR [total_input_quantity_bad]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_total_issue_quantity]  DEFAULT (0) FOR [total_output_quantity_good]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_component_aggregates_total_output_quantity_good2]  DEFAULT (0) FOR [total_output_quantity_bad]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_inout_total_adjustment_quantity]  DEFAULT (0) FOR [total_adjustment_quantity]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_history_total_preparation_time]  DEFAULT (0) FOR [total_preparation_time]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_history_total_production_time]  DEFAULT (0) FOR [total_transform_time]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_history_total_input_value]  DEFAULT (0) FOR [total_input_value]
GO
ALTER TABLE [tb_component_aggregates] ADD  CONSTRAINT [DF_tb_concept_production_history_total_output_value]  DEFAULT (0) FOR [total_output_value]
GO
ALTER TABLE [tb_component_comms_id] ADD  CONSTRAINT [DF_tb_component_communication_ids_communication_type_code]  DEFAULT (1) FOR [comms_type_code]
GO
ALTER TABLE [tb_component_types] ADD  CONSTRAINT [DF_tb_component_types_item_visible]  DEFAULT (1) FOR [item_visible]
GO
ALTER TABLE [tb_component_types] ADD  CONSTRAINT [DF_tb_component_types_next_id]  DEFAULT (1000) FOR [next_id]
GO
ALTER TABLE [tb_components] ADD  CONSTRAINT [DF_tb_component_component_type_code]  DEFAULT (1) FOR [component_type_code]
GO
ALTER TABLE [tb_components] ADD  CONSTRAINT [DF_tb_components_component_status_code]  DEFAULT (3) FOR [component_status_code]
GO
ALTER TABLE [tb_components] ADD  CONSTRAINT [DF_tb_component_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_components] ADD  CONSTRAINT [DF_tb_components_modified_date]  DEFAULT (getdate()) FOR [modified_date]
GO
ALTER TABLE [tb_concept] ADD  CONSTRAINT [DF_tb_concept_valid_from_date]  DEFAULT (convert(datetime,convert(varchar,getdate(),1))) FOR [valid_from_date]
GO
ALTER TABLE [tb_concept] ADD  CONSTRAINT [DF_tb_concept_valid_to_date]  DEFAULT (dateadd(year,1,convert(datetime,convert(varchar,getdate(),1)))) FOR [valid_to_date]
GO
ALTER TABLE [tb_concept] ADD  CONSTRAINT [DF_tb_concept_supply_type_code]  DEFAULT (1) FOR [supply_type_code]
GO
ALTER TABLE [tb_concept] ADD  CONSTRAINT [DF_tb_concept_enforced_approvals]  DEFAULT (0) FOR [enforced_approvals]
GO
ALTER TABLE [tb_concept_approvals] ADD  CONSTRAINT [DF_tb_concept_approvals_approval_rating]  DEFAULT (10) FOR [approval_rating]
GO
ALTER TABLE [tb_concept_approvals] ADD  CONSTRAINT [DF_tb_concept_approvals_approval_date]  DEFAULT (convert(datetime,convert(varchar,getdate(),1))) FOR [approval_date]
GO
ALTER TABLE [tb_concept_config] ADD  CONSTRAINT [DF_tb_concept_config_config_type_code]  DEFAULT (1) FOR [config_type_code]
GO
ALTER TABLE [tb_concept_config] ADD  CONSTRAINT [DF_tb_concept_config_digit_placement_holder]  DEFAULT (1) FOR [digit_placement_holder]
GO
ALTER TABLE [tb_concept_config] ADD  CONSTRAINT [DF_tb_concept_config_enforced]  DEFAULT (0) FOR [enforced]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_pack_weight]  DEFAULT (0) FOR [pack_weight]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_pack_length]  DEFAULT (0) FOR [pack_length]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_pack_width]  DEFAULT (0) FOR [pack_width]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_pack_height]  DEFAULT (0) FOR [pack_height]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_quantity_per_pack]  DEFAULT (0) FOR [quantity_per_pack]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_quantity_per_pallet]  DEFAULT (0) FOR [quantity_per_pallet]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_quantity_per_bag]  DEFAULT (0) FOR [quantity_per_bag]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_interleaves_per_pack]  DEFAULT (0) FOR [interleaves_per_pack]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_bags_per_pack]  DEFAULT (0) FOR [bags_per_pack]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_packs_high_per_pallet]  DEFAULT (0) FOR [packs_high_per_pallet]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_component_weight]  DEFAULT (0) FOR [component_weight]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_component_volume]  DEFAULT (0) FOR [component_volume]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_component_length]  DEFAULT (0) FOR [component_length]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_component_width]  DEFAULT (0) FOR [component_width]
GO
ALTER TABLE [tb_concept_product_dims] ADD  CONSTRAINT [DF_tb_concept_production_dims_component_height]  DEFAULT (0) FOR [component_height]
GO
ALTER TABLE [tb_concept_product_legacy] ADD  CONSTRAINT [DF_tb_concept_production_legacy_std_unit_material_cost]  DEFAULT (0) FOR [std_unit_material_cost]
GO
ALTER TABLE [tb_concept_product_legacy] ADD  CONSTRAINT [DF_tb_concept_production_legacy_std_unit_set_cost]  DEFAULT (0) FOR [std_unit_prepare_cost]
GO
ALTER TABLE [tb_concept_product_legacy] ADD  CONSTRAINT [DF_tb_concept_production_legacy_std_unit_run_cost]  DEFAULT (0) FOR [std_unit_transform_cost]
GO
ALTER TABLE [tb_concept_product_legacy] ADD  CONSTRAINT [DF_tb_concept_production_legacy_actual_unit_material_cost]  DEFAULT (0) FOR [actual_unit_material_cost]
GO
ALTER TABLE [tb_concept_product_legacy] ADD  CONSTRAINT [DF_tb_concept_production_legacy_actual_unit_set_cost]  DEFAULT (0) FOR [actual_unit_prepare_cost]
GO
ALTER TABLE [tb_concept_product_legacy] ADD  CONSTRAINT [DF_tb_concept_production_legacy_actual_unit_run_cost]  DEFAULT (0) FOR [actual_unit_transform_cost]
GO
ALTER TABLE [tb_concept_product_price_lists] ADD  CONSTRAINT [DF_tb_component_pricelists_unit_charge]  DEFAULT (0) FOR [unit_charge]
GO
ALTER TABLE [tb_concept_product_price_lists] ADD  CONSTRAINT [DF_tb_concept_production_pricelists_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_unit_charge]  DEFAULT (0) FOR [external_unit_charge]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_internal_unit_cost]  DEFAULT (0) FOR [internal_unit_cost]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Stock Policy Code]  DEFAULT (1) FOR [stock_policy_code]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_On Hold]  DEFAULT (0) FOR [on_hold]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Scrap Allowance]  DEFAULT (0) FOR [global_scrap_allowance]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Minimum Stock Level]  DEFAULT (0) FOR [minumum_stock_level]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Order Multiple Quantity]  DEFAULT (0) FOR [order_multiple_quantity]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Planning Window]  DEFAULT (1) FOR [planning_window_days]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Intake Buffer]  DEFAULT (0) FOR [buffer_days]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Standard Batch Size]  DEFAULT (0) FOR [standard_batch_size]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Maximum Batch Size]  DEFAULT (0) FOR [maximum_batch_size]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Plan With Batch Size]  DEFAULT (0) FOR [plan_with_batch_size]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Plan With Minimum Stock]  DEFAULT (0) FOR [plan_with_minimum_stock]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_Packed]  DEFAULT (0) FOR [packed_component]
GO
ALTER TABLE [tb_concept_products] ADD  CONSTRAINT [DF_tb_concept_production_On Hand Stock Level]  DEFAULT (0) FOR [quantity_onhand]
GO
ALTER TABLE [tb_concept_service] ADD  CONSTRAINT [DF_tb_concept_service_service_type_code]  DEFAULT (1) FOR [service_type_code]
GO
ALTER TABLE [tb_concept_service] ADD  CONSTRAINT [DF_tb_concept_service_total_charge]  DEFAULT (0) FOR [external_total_charge]
GO
ALTER TABLE [tb_concept_service] ADD  CONSTRAINT [DF_tb_concept_service_internal_total_cost]  DEFAULT (0) FOR [external_total_cost]
GO
ALTER TABLE [tb_concept_service] ADD  CONSTRAINT [DF_tb_concept_service_maximum_cases]  DEFAULT (0) FOR [maximum_units]
GO
ALTER TABLE [tb_concept_service] ADD  CONSTRAINT [DF_tb_concept_service_maximum_hours]  DEFAULT (0) FOR [maximum_time]
GO
ALTER TABLE [tb_concept_service_time_rates] ADD  CONSTRAINT [DF_tb_concept_service_time_rates_rate_interval]  DEFAULT (0) FOR [rate_interval]
GO
ALTER TABLE [tb_concept_service_time_rates] ADD  CONSTRAINT [DF_tb_concept_service_time_rates_time_rate]  DEFAULT (0) FOR [time_rate]
GO
ALTER TABLE [tb_concept_service_time_rates] ADD  CONSTRAINT [DF_tb_concept_service_time_rates_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_concept_service_types] ADD  CONSTRAINT [DF_tb_concept_service_types_service_type_code]  DEFAULT (1) FOR [service_type_code]
GO
ALTER TABLE [tb_concept_service_unit_rates] ADD  CONSTRAINT [DF_tb_concept_service_contract_unit_charge]  DEFAULT (0) FOR [unit_charge]
GO
ALTER TABLE [tb_concept_service_unit_rates] ADD  CONSTRAINT [DF_tb_concept_service_contract_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_currencies] ADD  CONSTRAINT [DF_tb_currencies_last_updated]  DEFAULT (getdate()) FOR [last_updated]
GO
ALTER TABLE [tb_currencies] ADD  CONSTRAINT [DF_tb_currencies_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_DESPATCH_STATUS_CODE]  DEFAULT (1) FOR [demand_status_code]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_ON_HOLD]  DEFAULT (0) FOR [on_hold]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_DELIVERY_ADDRESS_NUMBER]  DEFAULT (0) FOR [target_namespace]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_TOTAL_PRICE]  DEFAULT (0) FOR [total_charge]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_EXCHANGE_RATE]  DEFAULT (1) FOR [exchange_rate]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_payment_status_code]  DEFAULT (1) FOR [payment_status_code]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_paid_charge]  DEFAULT (0) FOR [paid_charge]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_paid_tax]  DEFAULT (0) FOR [paid_tax]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_DISCOUNT_PERCENT]  DEFAULT (0) FOR [discount_percent]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_DISCOUNT_DAYS]  DEFAULT (0) FOR [discount_days]
GO
ALTER TABLE [tb_demand] ADD  CONSTRAINT [DF_tb_demand_SETTLEMENT_PERCENT]  DEFAULT (0) FOR [settlement_percent]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_on_hold]  DEFAULT (0) FOR [on_hold]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_target_namespace]  DEFAULT (0) FOR [target_namespace]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_total_charge]  DEFAULT (0) FOR [total_charge]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_exchange_rate]  DEFAULT (1) FOR [exchange_rate]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_payment_status_code]  DEFAULT (1) FOR [payment_status_code]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_paid_charge]  DEFAULT (0) FOR [paid_charge]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_paid_tax]  DEFAULT (0) FOR [paid_tax]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_discount_percent]  DEFAULT (0) FOR [discount_percent]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_discount_days]  DEFAULT (0) FOR [discount_days]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_settlement_percent]  DEFAULT (0) FOR [settlement_percent]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_demand_containers] ADD  CONSTRAINT [DF_tb_demand_containers_modified_date]  DEFAULT (getdate()) FOR [modified_date]
GO
ALTER TABLE [tb_demand_products] ADD  CONSTRAINT [DF_tb_demand_goods_quantity_ordered]  DEFAULT (0) FOR [quantity_ordered]
GO
ALTER TABLE [tb_demand_products] ADD  CONSTRAINT [DF_tb_demand_goods_quantity_fulfilled]  DEFAULT (0) FOR [quantity_fulfilled]
GO
ALTER TABLE [tb_demand_products] ADD  CONSTRAINT [DF_tb_demand_goods_unit_charge]  DEFAULT (0) FOR [unit_charge]
GO
ALTER TABLE [tb_demand_products] ADD  CONSTRAINT [DF_tb_demand_goods_departure_date]  DEFAULT (getdate()) FOR [departure_date]
GO
ALTER TABLE [tb_demand_products] ADD  CONSTRAINT [DF_tb_demand_goods_arrival_date]  DEFAULT (getdate()) FOR [arrival_date]
GO
ALTER TABLE [tb_demand_products] ADD  CONSTRAINT [DF_tb_demand_goods_traceable_environment]  DEFAULT (0) FOR [traceable_environment]
GO
ALTER TABLE [tb_demand_services] ADD  CONSTRAINT [DF_tb_demand_services_recurrent_cycle]  DEFAULT (0) FOR [recurrent_cycle]
GO
ALTER TABLE [tb_demand_services] ADD  CONSTRAINT [DF_tb_demand_services_charge_day_of_month]  DEFAULT (0) FOR [charge_day_of_month]
GO
ALTER TABLE [tb_event_actions] ADD  CONSTRAINT [DF_tb_event_names_event_action_code]  DEFAULT (0) FOR [event_action_code]
GO
ALTER TABLE [tb_event_log] ADD  CONSTRAINT [DF_tb_event_log_log_date]  DEFAULT (getdate()) FOR [log_date]
GO
ALTER TABLE [tb_event_log] ADD  CONSTRAINT [DF_tb_event_log_UNIT_TIME]  DEFAULT (0) FOR [unit_time]
GO
ALTER TABLE [tb_event_log] ADD  CONSTRAINT [DF_tb_event_log_TOTAL_TIME]  DEFAULT (0) FOR [total_time]
GO
ALTER TABLE [tb_event_log] ADD  CONSTRAINT [DF_tb_event_log_QUANTITY_GOOD]  DEFAULT (0) FOR [quantity_good]
GO
ALTER TABLE [tb_event_log] ADD  CONSTRAINT [DF_tb_event_log_QUANTITY_SCRAP]  DEFAULT (0) FOR [quantity_bad]
GO
ALTER TABLE [tb_event_processes] ADD  CONSTRAINT [DF_tb_event_processes_quantity]  DEFAULT (0) FOR [quantity]
GO
ALTER TABLE [tb_event_processes] ADD  CONSTRAINT [DF_tb_event_processes_total_throughput_value]  DEFAULT (0) FOR [total_throughput_value]
GO
ALTER TABLE [tb_event_status] ADD  CONSTRAINT [DF_tb_event_status_event_status_code]  DEFAULT (1) FOR [event_status_code]
GO
ALTER TABLE [tb_events] ADD  CONSTRAINT [DF_tb_events_event_type_code]  DEFAULT (10) FOR [event_type_code]
GO
ALTER TABLE [tb_events] ADD  CONSTRAINT [DF_tb_events_event_status_code]  DEFAULT (10) FOR [event_status_code]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_CUSTOMER_STATUS_CODE]  DEFAULT (1) FOR [hold_status_code]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_tax_rate]  DEFAULT (0) FOR [tax_code]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_DISCOUNT_PERCENT]  DEFAULT (0) FOR [discount_percent]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_DISCOUNT_DAYS]  DEFAULT (0) FOR [discount_days]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_SETTLEMENT_PERCENT]  DEFAULT (0) FOR [settlement_percent]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_number_of_employees]  DEFAULT (1) FOR [number_of_employees]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_turnover_per_anum]  DEFAULT (0) FOR [turnover_per_anum]
GO
ALTER TABLE [tb_organisations] ADD  CONSTRAINT [DF_tb_organisations_CERTIFICATE_OF_CONFORMITY]  DEFAULT (0) FOR [certificate_of_conformity]
GO
ALTER TABLE [tb_people_roles] ADD  CONSTRAINT [DF_tb_people_roles_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_people_skills] ADD  CONSTRAINT [DF_tb_people_skills_creation_date]  DEFAULT (getdate()) FOR [creation_date]
GO
ALTER TABLE [tb_resource_simulations] ADD  CONSTRAINT [DF_tb_simulations_simulation_date]  DEFAULT (getdate()) FOR [simulation_date]
GO
ALTER TABLE [tb_resource_simulations] ADD  CONSTRAINT [DF_tb_simulations_simulation_successful]  DEFAULT (0) FOR [simulation_successful]
GO
ALTER TABLE [tb_resource_skill_levels] ADD  CONSTRAINT [DF_tb_skill_levels_skill_level_code]  DEFAULT (10) FOR [skill_level]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_supply_type_code]  DEFAULT (1) FOR [supply_type_code]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_supply_status_code]  DEFAULT (1) FOR [supply_status_code]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_BATCH_COST_STATUS_CODE]  DEFAULT (1) FOR [supply_cost_status_code]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_UNIT_THROUGHPUT_VALUE]  DEFAULT (0) FOR [unit_throughput_value]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_unit_input_value]  DEFAULT (0) FOR [unit_input_value]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_total_throughput_value]  DEFAULT (0) FOR [total_throughput_value]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_total_input_value]  DEFAULT (0) FOR [total_input_value]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_PLANNED_MATERIAL_COST]  DEFAULT (0) FOR [planned_material_cost]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_PLANNED_RUN_COST]  DEFAULT (0) FOR [planned_direct_cost]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_PLANNED_SET_COST]  DEFAULT (0) FOR [planned_set_cost]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_planned_direct_hours]  DEFAULT (0) FOR [planned_direct_hours]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_priority_days]  DEFAULT (0) FOR [priority_days]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_ACTUAL_MATERIAL_COST]  DEFAULT (0) FOR [actual_material_cost]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_ACTUAL_RUN_COST]  DEFAULT (0) FOR [actual_direct_cost]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_ACTUAL_SET_COST]  DEFAULT (0) FOR [actual_set_cost]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_ACTUAL_LABOUR_HOURS]  DEFAULT (0) FOR [actual_direct_hours]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_quantity_planned]  DEFAULT (0) FOR [quantity_planned]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_quantity_received]  DEFAULT (0) FOR [quantity_received]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_quantity_issued]  DEFAULT (0) FOR [quantity_issued]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_quantity_onhand]  DEFAULT (0) FOR [quantity_onhand]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_last_stock_check]  DEFAULT (getdate()) FOR [last_stock_check]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_last_issue_date]  DEFAULT (getdate()) FOR [last_issue_date]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_quantity_good_so_far]  DEFAULT (0) FOR [quantity_good_so_far]
GO
ALTER TABLE [tb_supply] ADD  CONSTRAINT [DF_tb_supply_quantity_bad_so_far]  DEFAULT (0) FOR [quantity_bad_so_far]
GO
ALTER TABLE [tb_supply_products] ADD  CONSTRAINT [DF_tb_supply_products_quantity_planned]  DEFAULT (0) FOR [quantity_planned]
GO
ALTER TABLE [tb_supply_products] ADD  CONSTRAINT [DF_tb_supply_products_quantity_received]  DEFAULT (0) FOR [quantity_received]
GO
ALTER TABLE [tb_supply_products] ADD  CONSTRAINT [DF_tb_supply_products_quantity_issued]  DEFAULT (0) FOR [quantity_issued]
GO
ALTER TABLE [tb_supply_products] ADD  CONSTRAINT [DF_tb_supply_products_quantity_onhand]  DEFAULT (0) FOR [quantity_onhand]
GO
ALTER TABLE [tb_supply_products] ADD  CONSTRAINT [DF_tb_supply_products_last_stock_check]  DEFAULT (getdate()) FOR [last_stock_check]
GO
ALTER TABLE [tb_supply_products] ADD  CONSTRAINT [DF_tb_supply_products_last_issue_date]  DEFAULT (getdate()) FOR [last_issue_date]
GO
ALTER TABLE [tb_supply_products] ADD  CONSTRAINT [DF_tb_supply_products_quantity_good]  DEFAULT (0) FOR [quantity_good_so_far]
GO
ALTER TABLE [tb_supply_types] ADD  CONSTRAINT [DF_tb_supply_types_supply_type_code]  DEFAULT (1) FOR [supply_type_code]
GO
ALTER TABLE [tb_units_of_measure] ADD  CONSTRAINT [DF_tb_units_of_measure_decimal_precision]  DEFAULT (0) FOR [decimal_precision]
GO
ALTER TABLE [tb_units_of_time] ADD  CONSTRAINT [DF_tb_units_of_time_decimal_precision]  DEFAULT (0) FOR [decimal_precision]
GO
ALTER TABLE [tb_uom_conversions] ADD  CONSTRAINT [DF_tb_uom_conversions_conversion_quantity]  DEFAULT (1) FOR [conversion_quantity]
GO
ALTER TABLE [tb_uot_conversions] ADD  CONSTRAINT [DF_tb_uot_conversions_conversion_quantity]  DEFAULT (1) FOR [conversion_quantity]
GO
ALTER TABLE [tb_allocations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_allocations_tb_alloaction_status] FOREIGN KEY([allocation_status_code])
REFERENCES [tb_alloaction_status] ([allocation_status_code])
GO
ALTER TABLE [tb_allocations] CHECK CONSTRAINT [FK_tb_allocations_tb_alloaction_status]
GO
ALTER TABLE [tb_allocations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_allocations_tb_allocations_behaviour] FOREIGN KEY([chain_behaviour_code])
REFERENCES [tb_allocations_behaviour] ([chain_behaviour_code])
GO
ALTER TABLE [tb_allocations] CHECK CONSTRAINT [FK_tb_allocations_tb_allocations_behaviour]
GO
ALTER TABLE [tb_allocations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_allocations_tb_component_classes] FOREIGN KEY([component_class_code])
REFERENCES [tb_component_classes] ([component_class_code])
GO
ALTER TABLE [tb_allocations] CHECK CONSTRAINT [FK_tb_allocations_tb_component_classes]
GO
ALTER TABLE [tb_allocations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_allocations_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_allocations] CHECK CONSTRAINT [FK_tb_allocations_tb_components]
GO
ALTER TABLE [tb_assemblies]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_assemblies_tb_assembly_types] FOREIGN KEY([assembly_type_code])
REFERENCES [tb_assembly_types] ([assembly_type_code])
GO
ALTER TABLE [tb_assemblies] CHECK CONSTRAINT [FK_tb_assemblies_tb_assembly_types]
GO
ALTER TABLE [tb_assemblies]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_assemblies_tb_cash_codes] FOREIGN KEY([cash_code])
REFERENCES [tb_cash_codes] ([cash_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_assemblies] CHECK CONSTRAINT [FK_tb_assemblies_tb_cash_codes]
GO
ALTER TABLE [tb_assemblies]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_assemblies_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_assemblies] CHECK CONSTRAINT [FK_tb_assemblies_tb_components]
GO
ALTER TABLE [tb_assemblies_legacy]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_assemblies_legacy_tb_assemblies] FOREIGN KEY([component_id])
REFERENCES [tb_assemblies] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_assemblies_legacy] CHECK CONSTRAINT [FK_tb_assemblies_legacy_tb_assemblies]
GO
ALTER TABLE [tb_assembly_narratives]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_assembly_narratives_tb_assemblies] FOREIGN KEY([component_id])
REFERENCES [tb_assemblies] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_assembly_narratives] CHECK CONSTRAINT [FK_tb_assembly_narratives_tb_assemblies]
GO
ALTER TABLE [tb_calendar]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_calendar_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_calendar] CHECK CONSTRAINT [FK_tb_calendar_tb_components]
GO
ALTER TABLE [tb_calendar_breaks]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_calendar_breaks_tb_calendar_days] FOREIGN KEY([component_id], [day_number])
REFERENCES [tb_calendar_days] ([component_id], [day_number])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_calendar_breaks] CHECK CONSTRAINT [FK_tb_calendar_breaks_tb_calendar_days]
GO
ALTER TABLE [tb_calendar_days]  WITH CHECK ADD  CONSTRAINT [FK_tb_calendar_days_tb_calendar] FOREIGN KEY([component_id])
REFERENCES [tb_calendar] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_calendar_days] CHECK CONSTRAINT [FK_tb_calendar_days_tb_calendar]
GO
ALTER TABLE [tb_calendar_exception_assignments]  WITH CHECK ADD  CONSTRAINT [FK_tb_calendar_exception_assignments_tb_calendar] FOREIGN KEY([component_id])
REFERENCES [tb_calendar] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_calendar_exception_assignments] CHECK CONSTRAINT [FK_tb_calendar_exception_assignments_tb_calendar]
GO
ALTER TABLE [tb_calendar_exception_assignments]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_calendar_exception_assignments_tb_calendar_exceptions] FOREIGN KEY([exception_id])
REFERENCES [tb_calendar_exceptions] ([exception_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_calendar_exception_assignments] CHECK CONSTRAINT [FK_tb_calendar_exception_assignments_tb_calendar_exceptions]
GO
ALTER TABLE [tb_component_aggregates]  WITH CHECK ADD  CONSTRAINT [FK_tb_component_aggregates_tb_concept] FOREIGN KEY([component_id])
REFERENCES [tb_concept] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_component_aggregates] CHECK CONSTRAINT [FK_tb_component_aggregates_tb_concept]
GO
ALTER TABLE [tb_component_comms_id]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_component_comms_id_tb_comminucation_types] FOREIGN KEY([comms_type_code])
REFERENCES [tb_component_comms_types] ([comms_type_code])
GO
ALTER TABLE [tb_component_comms_id] CHECK CONSTRAINT [FK_tb_component_comms_id_tb_comminucation_types]
GO
ALTER TABLE [tb_component_comms_id]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_component_comms_id_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_component_comms_id] CHECK CONSTRAINT [FK_tb_component_comms_id_tb_components]
GO
ALTER TABLE [tb_component_types]  WITH CHECK ADD  CONSTRAINT [FK_tb_component_types_tb_component_classes] FOREIGN KEY([component_class_code])
REFERENCES [tb_component_classes] ([component_class_code])
GO
ALTER TABLE [tb_component_types] CHECK CONSTRAINT [FK_tb_component_types_tb_component_classes]
GO
ALTER TABLE [tb_components]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_components_tb_component_status] FOREIGN KEY([component_status_code])
REFERENCES [tb_component_status] ([component_status_code])
GO
ALTER TABLE [tb_components] CHECK CONSTRAINT [FK_tb_components_tb_component_status]
GO
ALTER TABLE [tb_components]  WITH CHECK ADD  CONSTRAINT [FK_tb_components_tb_component_types] FOREIGN KEY([component_class_code], [component_type_code])
REFERENCES [tb_component_types] ([component_class_code], [component_type_code])
GO
ALTER TABLE [tb_components] CHECK CONSTRAINT [FK_tb_components_tb_component_types]
GO
ALTER TABLE [tb_concept]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept] CHECK CONSTRAINT [FK_tb_concept_tb_components]
GO
ALTER TABLE [tb_concept]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_tb_concept_features] FOREIGN KEY([concept_feature])
REFERENCES [tb_concept_features] ([concept_feature])
NOT FOR REPLICATION 
GO
ALTER TABLE [tb_concept] NOCHECK CONSTRAINT [FK_tb_concept_tb_concept_features]
GO
ALTER TABLE [tb_concept]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_tb_concept_group_codes] FOREIGN KEY([concept_group_code])
REFERENCES [tb_concept_group_codes] ([concept_group_code])
NOT FOR REPLICATION 
GO
ALTER TABLE [tb_concept] NOCHECK CONSTRAINT [FK_tb_concept_tb_concept_group_codes]
GO
ALTER TABLE [tb_concept]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_tb_supply_types] FOREIGN KEY([supply_type_code])
REFERENCES [tb_supply_types] ([supply_type_code])
GO
ALTER TABLE [tb_concept] CHECK CONSTRAINT [FK_tb_concept_tb_supply_types]
GO
ALTER TABLE [tb_concept]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_tb_tax_rates] FOREIGN KEY([tax_code])
REFERENCES [tb_tax_rates] ([tax_code])
GO
ALTER TABLE [tb_concept] CHECK CONSTRAINT [FK_tb_concept_tb_tax_rates]
GO
ALTER TABLE [tb_concept_approvals]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_approvals_tb_concept] FOREIGN KEY([component_id])
REFERENCES [tb_concept] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_approvals] CHECK CONSTRAINT [FK_tb_concept_approvals_tb_concept]
GO
ALTER TABLE [tb_concept_config]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_config_tb_concept] FOREIGN KEY([component_id])
REFERENCES [tb_concept] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_config] CHECK CONSTRAINT [FK_tb_concept_config_tb_concept]
GO
ALTER TABLE [tb_concept_config]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_config_tb_concept_config_types] FOREIGN KEY([config_type_code])
REFERENCES [tb_concept_config_types] ([config_type_code])
GO
ALTER TABLE [tb_concept_config] CHECK CONSTRAINT [FK_tb_concept_config_tb_concept_config_types]
GO
ALTER TABLE [tb_concept_product_dims]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_production_dims_tb_concept_production] FOREIGN KEY([component_id])
REFERENCES [tb_concept_products] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_product_dims] CHECK CONSTRAINT [FK_tb_concept_production_dims_tb_concept_production]
GO
ALTER TABLE [tb_concept_product_legacy]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_production_legacy_tb_concept_production] FOREIGN KEY([component_id])
REFERENCES [tb_concept_products] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_product_legacy] CHECK CONSTRAINT [FK_tb_concept_production_legacy_tb_concept_production]
GO
ALTER TABLE [tb_concept_product_price_lists]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_production_price_lists_tb_concept_production] FOREIGN KEY([component_id])
REFERENCES [tb_concept_products] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_product_price_lists] CHECK CONSTRAINT [FK_tb_concept_production_price_lists_tb_concept_production]
GO
ALTER TABLE [tb_concept_product_price_lists]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_production_price_lists_tb_currencies] FOREIGN KEY([denomination])
REFERENCES [tb_currencies] ([denomination])
GO
ALTER TABLE [tb_concept_product_price_lists] CHECK CONSTRAINT [FK_tb_concept_production_price_lists_tb_currencies]
GO
ALTER TABLE [tb_concept_product_text]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_production_text_tb_concept_production] FOREIGN KEY([component_id])
REFERENCES [tb_concept_products] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_product_text] CHECK CONSTRAINT [FK_tb_concept_production_text_tb_concept_production]
GO
ALTER TABLE [tb_concept_products]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_production_tb_concept] FOREIGN KEY([component_id])
REFERENCES [tb_concept] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_products] CHECK CONSTRAINT [FK_tb_concept_production_tb_concept]
GO
ALTER TABLE [tb_concept_products]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_production_tb_concept_production_abc] FOREIGN KEY([abc_code])
REFERENCES [tb_concept_product_abc] ([abc_code])
NOT FOR REPLICATION 
GO
ALTER TABLE [tb_concept_products] NOCHECK CONSTRAINT [FK_tb_concept_production_tb_concept_production_abc]
GO
ALTER TABLE [tb_concept_products]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_production_tb_concept_production_policies] FOREIGN KEY([stock_policy_code])
REFERENCES [tb_concept_product_policies] ([stock_policy_code])
GO
ALTER TABLE [tb_concept_products] CHECK CONSTRAINT [FK_tb_concept_production_tb_concept_production_policies]
GO
ALTER TABLE [tb_concept_products]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_production_tb_uom_conversions] FOREIGN KEY([external_unit_of_measure], [internal_unit_of_measure])
REFERENCES [tb_uom_conversions] ([external_unit_of_measure], [internal_unit_of_measure])
GO
ALTER TABLE [tb_concept_products] CHECK CONSTRAINT [FK_tb_concept_production_tb_uom_conversions]
GO
ALTER TABLE [tb_concept_service]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_service_tb_concept] FOREIGN KEY([component_id])
REFERENCES [tb_concept] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_service] CHECK CONSTRAINT [FK_tb_concept_service_tb_concept]
GO
ALTER TABLE [tb_concept_service]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_service_tb_concept_service_types] FOREIGN KEY([service_type_code])
REFERENCES [tb_concept_service_types] ([service_type_code])
GO
ALTER TABLE [tb_concept_service] CHECK CONSTRAINT [FK_tb_concept_service_tb_concept_service_types]
GO
ALTER TABLE [tb_concept_service]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_service_tb_skill_levels_from] FOREIGN KEY([skill_class_code], [from_skill_level])
REFERENCES [tb_resource_skill_levels] ([skill_class_code], [skill_level])
GO
ALTER TABLE [tb_concept_service] CHECK CONSTRAINT [FK_tb_concept_service_tb_skill_levels_from]
GO
ALTER TABLE [tb_concept_service]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_service_tb_skill_levels_to] FOREIGN KEY([skill_class_code], [to_skill_level])
REFERENCES [tb_resource_skill_levels] ([skill_class_code], [skill_level])
GO
ALTER TABLE [tb_concept_service] CHECK CONSTRAINT [FK_tb_concept_service_tb_skill_levels_to]
GO
ALTER TABLE [tb_concept_service]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_concept_service_tb_skill_levels_transform] FOREIGN KEY([skill_class_code], [transformer_skill_level])
REFERENCES [tb_resource_skill_levels] ([skill_class_code], [skill_level])
GO
ALTER TABLE [tb_concept_service] CHECK CONSTRAINT [FK_tb_concept_service_tb_skill_levels_transform]
GO
ALTER TABLE [tb_concept_service]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_service_tb_uot_conversions] FOREIGN KEY([external_unit_of_time], [internal_unit_of_time])
REFERENCES [tb_uot_conversions] ([external_unit_of_time], [internal_unit_of_time])
GO
ALTER TABLE [tb_concept_service] CHECK CONSTRAINT [FK_tb_concept_service_tb_uot_conversions]
GO
ALTER TABLE [tb_concept_service_time_rates]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_service_time_rates_tb_concept_service] FOREIGN KEY([component_id])
REFERENCES [tb_concept_service] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_service_time_rates] CHECK CONSTRAINT [FK_tb_concept_service_time_rates_tb_concept_service]
GO
ALTER TABLE [tb_concept_service_time_rates]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_service_time_rates_tb_currencies] FOREIGN KEY([denomination])
REFERENCES [tb_currencies] ([denomination])
GO
ALTER TABLE [tb_concept_service_time_rates] CHECK CONSTRAINT [FK_tb_concept_service_time_rates_tb_currencies]
GO
ALTER TABLE [tb_concept_service_unit_rates]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_service_unit_rates_tb_concept_service] FOREIGN KEY([component_id])
REFERENCES [tb_concept_service] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_concept_service_unit_rates] CHECK CONSTRAINT [FK_tb_concept_service_unit_rates_tb_concept_service]
GO
ALTER TABLE [tb_concept_service_unit_rates]  WITH CHECK ADD  CONSTRAINT [FK_tb_concept_service_unit_rates_tb_currencies] FOREIGN KEY([denomination])
REFERENCES [tb_currencies] ([denomination])
GO
ALTER TABLE [tb_concept_service_unit_rates] CHECK CONSTRAINT [FK_tb_concept_service_unit_rates_tb_currencies]
GO
ALTER TABLE [tb_demand]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_demand_tb_cash_codes] FOREIGN KEY([cash_code])
REFERENCES [tb_cash_codes] ([cash_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_demand] CHECK CONSTRAINT [FK_tb_demand_tb_cash_codes]
GO
ALTER TABLE [tb_demand]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_demand_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_demand] CHECK CONSTRAINT [FK_tb_demand_tb_components]
GO
ALTER TABLE [tb_demand]  WITH CHECK ADD  CONSTRAINT [FK_tb_demand_tb_demand_status] FOREIGN KEY([demand_status_code])
REFERENCES [tb_demand_status] ([demand_status_code])
GO
ALTER TABLE [tb_demand] CHECK CONSTRAINT [FK_tb_demand_tb_demand_status]
GO
ALTER TABLE [tb_demand]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_demand_tb_payment_status] FOREIGN KEY([payment_status_code])
REFERENCES [tb_payment_status] ([payment_status_code])
GO
ALTER TABLE [tb_demand] CHECK CONSTRAINT [FK_tb_demand_tb_payment_status]
GO
ALTER TABLE [tb_demand]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_demand_tb_tax_rates] FOREIGN KEY([tax_code])
REFERENCES [tb_tax_rates] ([tax_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_demand] CHECK CONSTRAINT [FK_tb_demand_tb_tax_rates]
GO
ALTER TABLE [tb_demand_containers]  WITH CHECK ADD  CONSTRAINT [FK_tb_demand_containers_tb_cash_codes] FOREIGN KEY([cash_code])
REFERENCES [tb_cash_codes] ([cash_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_demand_containers] CHECK CONSTRAINT [FK_tb_demand_containers_tb_cash_codes]
GO
ALTER TABLE [tb_demand_containers]  WITH CHECK ADD  CONSTRAINT [FK_tb_demand_containers_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_demand_containers] CHECK CONSTRAINT [FK_tb_demand_containers_tb_components]
GO
ALTER TABLE [tb_demand_containers]  WITH CHECK ADD  CONSTRAINT [FK_tb_demand_containers_tb_payment_status] FOREIGN KEY([payment_status_code])
REFERENCES [tb_payment_status] ([payment_status_code])
GO
ALTER TABLE [tb_demand_containers] CHECK CONSTRAINT [FK_tb_demand_containers_tb_payment_status]
GO
ALTER TABLE [tb_demand_containers]  WITH CHECK ADD  CONSTRAINT [FK_tb_demand_containers_tb_tax_rates] FOREIGN KEY([tax_code])
REFERENCES [tb_tax_rates] ([tax_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_demand_containers] CHECK CONSTRAINT [FK_tb_demand_containers_tb_tax_rates]
GO
ALTER TABLE [tb_demand_products]  WITH CHECK ADD  CONSTRAINT [FK_tb_demand_products_tb_demand] FOREIGN KEY([component_id])
REFERENCES [tb_demand] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_demand_products] CHECK CONSTRAINT [FK_tb_demand_products_tb_demand]
GO
ALTER TABLE [tb_demand_services]  WITH CHECK ADD  CONSTRAINT [FK_tb_demand_services_tb_demand] FOREIGN KEY([component_id])
REFERENCES [tb_demand] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_demand_services] CHECK CONSTRAINT [FK_tb_demand_services_tb_demand]
GO
ALTER TABLE [tb_event_log]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_event_log_tb_event_status] FOREIGN KEY([event_status_code])
REFERENCES [tb_event_status] ([event_status_code])
GO
ALTER TABLE [tb_event_log] CHECK CONSTRAINT [FK_tb_event_log_tb_event_status]
GO
ALTER TABLE [tb_event_log]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_event_log_tb_events] FOREIGN KEY([component_id], [event_id])
REFERENCES [tb_events] ([component_id], [event_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_event_log] CHECK CONSTRAINT [FK_tb_event_log_tb_events]
GO
ALTER TABLE [tb_event_processes]  WITH CHECK ADD  CONSTRAINT [FK_tb_event_processes_tb_events] FOREIGN KEY([component_id], [event_id])
REFERENCES [tb_events] ([component_id], [event_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_event_processes] CHECK CONSTRAINT [FK_tb_event_processes_tb_events]
GO
ALTER TABLE [tb_event_responses]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_event_triggers_tb_events] FOREIGN KEY([component_id], [event_id])
REFERENCES [tb_events] ([component_id], [event_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_event_responses] CHECK CONSTRAINT [FK_tb_event_triggers_tb_events]
GO
ALTER TABLE [tb_event_triggers]  WITH CHECK ADD  CONSTRAINT [FK_tb_event_triggers_tb_events1] FOREIGN KEY([component_id], [event_id])
REFERENCES [tb_events] ([component_id], [event_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_event_triggers] CHECK CONSTRAINT [FK_tb_event_triggers_tb_events1]
GO
ALTER TABLE [tb_events]  WITH CHECK ADD  CONSTRAINT [FK_tb_events_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_events] CHECK CONSTRAINT [FK_tb_events_tb_components]
GO
ALTER TABLE [tb_events]  WITH CHECK ADD  CONSTRAINT [FK_tb_events_tb_event_actions] FOREIGN KEY([event_type_code])
REFERENCES [tb_event_actions] ([event_action_code])
GO
ALTER TABLE [tb_events] CHECK CONSTRAINT [FK_tb_events_tb_event_actions]
GO
ALTER TABLE [tb_events]  WITH CHECK ADD  CONSTRAINT [FK_tb_events_tb_event_status] FOREIGN KEY([event_status_code])
REFERENCES [tb_event_status] ([event_status_code])
GO
ALTER TABLE [tb_events] CHECK CONSTRAINT [FK_tb_events_tb_event_status]
GO
ALTER TABLE [tb_events]  WITH CHECK ADD  CONSTRAINT [FK_tb_events_tb_event_types] FOREIGN KEY([event_type_code])
REFERENCES [tb_event_types] ([event_type_code])
GO
ALTER TABLE [tb_events] CHECK CONSTRAINT [FK_tb_events_tb_event_types]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_cash_codes] FOREIGN KEY([cash_code])
REFERENCES [tb_cash_codes] ([cash_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_organisations] CHECK CONSTRAINT [FK_tb_organisations_tb_cash_codes]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_organisations] CHECK CONSTRAINT [FK_tb_organisations_tb_components]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_currencies] FOREIGN KEY([denomination])
REFERENCES [tb_currencies] ([denomination])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_organisations] CHECK CONSTRAINT [FK_tb_organisations_tb_currencies]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_organisation_area_codes] FOREIGN KEY([area_code])
REFERENCES [tb_organisation_area_codes] ([area_code])
NOT FOR REPLICATION 
GO
ALTER TABLE [tb_organisations] NOCHECK CONSTRAINT [FK_tb_organisations_tb_organisation_area_codes]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_organisation_categories] FOREIGN KEY([organisation_category_code])
REFERENCES [tb_organisation_categories] ([organisation_category_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_organisations] CHECK CONSTRAINT [FK_tb_organisations_tb_organisation_categories]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_organisation_hold_status] FOREIGN KEY([hold_status_code])
REFERENCES [tb_organisation_hold_status] ([hold_status_code])
GO
ALTER TABLE [tb_organisations] CHECK CONSTRAINT [FK_tb_organisations_tb_organisation_hold_status]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_organisation_sector_codes] FOREIGN KEY([sector_code])
REFERENCES [tb_organisation_sector_codes] ([sector_code])
NOT FOR REPLICATION 
GO
ALTER TABLE [tb_organisations] NOCHECK CONSTRAINT [FK_tb_organisations_tb_organisation_sector_codes]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_organisation_sources] FOREIGN KEY([organisation_source_id])
REFERENCES [tb_organisation_sources] ([organisation_source_id])
NOT FOR REPLICATION 
GO
ALTER TABLE [tb_organisations] NOCHECK CONSTRAINT [FK_tb_organisations_tb_organisation_sources]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_organisation_status] FOREIGN KEY([organisation_status_code])
REFERENCES [tb_organisation_status] ([organisation_status_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_organisations] CHECK CONSTRAINT [FK_tb_organisations_tb_organisation_status]
GO
ALTER TABLE [tb_organisations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_organisations_tb_tax_rates] FOREIGN KEY([tax_code])
REFERENCES [tb_tax_rates] ([tax_code])
ON UPDATE CASCADE
GO
ALTER TABLE [tb_organisations] CHECK CONSTRAINT [FK_tb_organisations_tb_tax_rates]
GO
ALTER TABLE [tb_people]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_people_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_people] CHECK CONSTRAINT [FK_tb_people_tb_components]
GO
ALTER TABLE [tb_people]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_people_tb_people_titles] FOREIGN KEY([title])
REFERENCES [tb_people_titles] ([title])
NOT FOR REPLICATION 
GO
ALTER TABLE [tb_people] NOCHECK CONSTRAINT [FK_tb_people_tb_people_titles]
GO
ALTER TABLE [tb_people_roles]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_people_roles_tb_people] FOREIGN KEY([component_id])
REFERENCES [tb_people] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_people_roles] CHECK CONSTRAINT [FK_tb_people_roles_tb_people]
GO
ALTER TABLE [tb_people_roles]  WITH CHECK ADD  CONSTRAINT [FK_tb_people_roles_tb_people_role_types] FOREIGN KEY([role_code])
REFERENCES [tb_people_role_types] ([role_code])
GO
ALTER TABLE [tb_people_roles] CHECK CONSTRAINT [FK_tb_people_roles_tb_people_role_types]
GO
ALTER TABLE [tb_people_skills]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_people_skills_tb_people] FOREIGN KEY([component_id])
REFERENCES [tb_people] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_people_skills] CHECK CONSTRAINT [FK_tb_people_skills_tb_people]
GO
ALTER TABLE [tb_people_skills]  WITH CHECK ADD  CONSTRAINT [FK_tb_people_skills_tb_skill_levels] FOREIGN KEY([skill_class_code], [skill_level])
REFERENCES [tb_resource_skill_levels] ([skill_class_code], [skill_level])
GO
ALTER TABLE [tb_people_skills] CHECK CONSTRAINT [FK_tb_people_skills_tb_skill_levels]
GO
ALTER TABLE [tb_resource_simulations]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_simulations_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_resource_simulations] CHECK CONSTRAINT [FK_tb_simulations_tb_components]
GO
ALTER TABLE [tb_resource_skill_levels]  WITH CHECK ADD  CONSTRAINT [FK_tb_skill_levels_tb_skill_classes] FOREIGN KEY([skill_class_code])
REFERENCES [tb_resource_skill_classes] ([skill_class_code])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_resource_skill_levels] CHECK CONSTRAINT [FK_tb_skill_levels_tb_skill_classes]
GO
ALTER TABLE [tb_supply]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_supply_tb_components] FOREIGN KEY([component_id])
REFERENCES [tb_components] ([component_id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [tb_supply] CHECK CONSTRAINT [FK_tb_supply_tb_components]
GO
ALTER TABLE [tb_supply]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_supply_tb_supply_types] FOREIGN KEY([supply_type_code])
REFERENCES [tb_supply_types] ([supply_type_code])
GO
ALTER TABLE [tb_supply] CHECK CONSTRAINT [FK_tb_supply_tb_supply_types]
GO
ALTER TABLE [tb_uom_conversions]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_uom_conversions_tb_units_of_measure] FOREIGN KEY([internal_unit_of_measure])
REFERENCES [tb_units_of_measure] ([unit_of_measure])
GO
ALTER TABLE [tb_uom_conversions] CHECK CONSTRAINT [FK_tb_uom_conversions_tb_units_of_measure]
GO
ALTER TABLE [tb_uom_conversions]  WITH NOCHECK ADD  CONSTRAINT [FK_tb_uom_conversions_tb_units_of_measure1] FOREIGN KEY([external_unit_of_measure])
REFERENCES [tb_units_of_measure] ([unit_of_measure])
GO
ALTER TABLE [tb_uom_conversions] CHECK CONSTRAINT [FK_tb_uom_conversions_tb_units_of_measure1]
GO
ALTER TABLE [tb_uot_conversions]  WITH CHECK ADD  CONSTRAINT [FK_tb_uot_conversions_tb_units_of_time] FOREIGN KEY([external_unit_of_time])
REFERENCES [tb_units_of_time] ([unit_of_time])
GO
ALTER TABLE [tb_uot_conversions] CHECK CONSTRAINT [FK_tb_uot_conversions_tb_units_of_time]
GO
ALTER TABLE [tb_uot_conversions]  WITH CHECK ADD  CONSTRAINT [FK_tb_uot_conversions_tb_units_of_time1] FOREIGN KEY([internal_unit_of_time])
REFERENCES [tb_units_of_time] ([unit_of_time])
GO
ALTER TABLE [tb_uot_conversions] CHECK CONSTRAINT [FK_tb_uot_conversions_tb_units_of_time1]
GO
/******** LOOKUP DATA *****************************************************/

INSERT INTO [dbo].[tb_alloaction_status] ([allocation_status_code], [allocation_status])
VALUES (10, 'Allocated')
, (20, 'In progress')
, (30, 'Complete')
, (40, 'Cancelled')
;
INSERT INTO [dbo].[tb_allocations_behaviour] ([chain_behaviour_code], [chain_behaviour])
VALUES (1, 'Summate')
, (2, 'Maximise')
, (3, 'Fixed')
;
INSERT INTO [dbo].[tb_assembly_types] ([assembly_type_code], [assembly_type])
VALUES (10, 'Group')
, (20, 'Instance')
;
INSERT INTO [dbo].[tb_cash_codes] ([cash_code], [cash_code_description])
VALUES ('INTERNAL', 'Internal Transactions')
, ('PRESALES', 'Pre-sales contact')
;
INSERT INTO [dbo].[tb_component_classes] ([component_class_code], [component_class])
VALUES (10, 'Concept')
, (20, 'Demand')
, (30, 'Supply')
, (40, 'Resource')
, (50, 'Transform')
, (60, 'Delivery')
, (70, 'Value')
, (80, 'Time')
, (90, 'Space')
;
INSERT INTO [dbo].[tb_component_comms_types] ([comms_type_code], [communication_type])
VALUES (10, 'Land Line')
, (20, 'Mobile')
, (30, 'Fax')
, (40, 'E-mail')
;
INSERT INTO [dbo].[tb_component_status] ([component_status_code], [component_status])
VALUES (10, 'Dormant')
, (20, 'In-progress')
, (30, 'Active')
, (40, 'On Hold')
, (50, 'Dead')
;
INSERT INTO [dbo].[tb_component_types] ([component_class_code], [component_type_code], [component_type], [profile_name], [item_visible], [namespace_prefix], [next_id])
VALUES (10, 10, 'Service', 'Service', 1, 'SVR', 1000)
, (10, 20, 'Product', 'Goods', 1, 'PRD', 1000)
, (10, 30, 'Junction', 'Phantom', 1, 'PHA', 1000)
, (10, 40, 'Uncoded', 'Raw Material', 1, 'MTR', 1000)
, (10, 50, 'Encoded', 'Bought Out Part', 1, 'BOP', 1000)
, (10, 60, 'Container', 'Configurator', 1, 'CFG', 1000)
, (20, 70, 'Output', 'Purchase Receipt', 1, 'POR', 1000)
, (20, 80, 'Input', 'Sales Order Detail', 1, 'SOI', 1000)
, (20, 90, 'Container', 'Order Header', 1, 'SOH', 1000)
, (30, 100, 'Container', '+MPS Entry', 1, 'MPS', 1000)
, (30, 110, 'Product', 'Available Stock', 1, 'WRK', 1000)
, (30, 120, 'Service', 'Service Order', 1, 'SRV', 1000)
, (30, 130, 'Allocation', 'Requirements', 1, 'ALC', 1000)
, (40, 140, 'Assemblage', 'Resource', 1, 'RES', 1000)
, (40, 150, 'Person', 'Contact', 1, 'PEO', 1000)
, (40, 160, 'Organisation', 'Company', 1, 'COM', 1000)
, (40, 170, 'Simulations', 'Plan', 1, 'PLAN', 1000)
, (40, 180, 'Profile', '+Settings/Profiles', 1, 'COL', 1000)
, (50, 190, 'Junction', 'Phantom Order', 1, 'WPH', 1000)
, (50, 200, 'Goods', '+Production Operation', 1, 'OPN', 1000)
, (50, 210, 'Process', '+Service Operation', 1, 'PRO', 1000)
, (50, 220, 'External', '+Sub-con Operation', 1, 'SUB', 1000)
, (60, 230, 'Output', '+Despatch', 1, 'DNT', 1000)
, (60, 240, 'Input', '+Goods Inwards', 1, 'GRN', 1000)
, (60, 250, 'Container', '+Delivery Note', 1, 'DN', 1000)
, (70, 260, 'Input', '+Income', 1, 'SIV', 1000)
, (70, 270, 'Output', '+Expense', 1, 'PIV', 1000)
, (80, 280, 'Calendar', 'Resource calendars', 1, 'CAL', 1000)
, (80, 290, 'Schedule', 'Resource Diary', 1, 'SCH', 1000)
, (90, 300, 'Internal', 'Stock Location', 1, 'LOC', 1000)
, (90, 310, 'External', 'Address', 1, 'ADR', 1000)
;
INSERT INTO [dbo].[tb_concept_config_types] ([config_type_code], [config_type])
VALUES (10, 'container')
, (20, 'matrix')
;
INSERT INTO [dbo].[tb_concept_product_abc] ([abc_code], [check_days])
VALUES ('a', 90)
, ('B', 180)
, ('C', 360)
, ('D', null)
, ('E', null)
, ('F', null)
, ('N', 365)
;
INSERT INTO [dbo].[tb_concept_product_policies] ([stock_policy_code], [stock_policy])
VALUES (10, 'Planned')
, (20, 'Non-Stocked')
, (30, 'Kanban')
;
INSERT INTO [dbo].[tb_concept_service_types] ([service_type_code], [service_type])
VALUES (10, 'units')
, (20, 'time')
;
INSERT INTO [dbo].[tb_currencies] ([denomination], [currency_name], [exchange_rate], [last_updated], [creation_date])
VALUES ('£', 'Sterling', 1, '20001222', null)
;
INSERT INTO [dbo].[tb_demand_status] ([demand_status_code], [demand_status])
VALUES (10, 'Proposed')
, (20, 'In-progress')
, (30, 'Complete')
, (40, 'Cancelled')
;
INSERT INTO [dbo].[tb_event_actions] ([event_action_code], [event_action])
VALUES (10, 'Change')
, (20, 'Event Request')
, (30, 'Event Send')
, (40, 'External Issue')
, (50, 'External Receipt')
, (60, 'Free Receipt')
, (70, 'Input Return')
, (80, 'Internal Issue')
, (90, 'Internal Receipt')
, (100, 'On Ready')
, (110, 'Output Return')
, (120, 'Perparation')
, (130, 'Product Check')
, (140, 'Product Movement')
, (150, 'Transformation')
, (160, 'Unplanned Issue')
, (170, 'Payment')
;
INSERT INTO [dbo].[tb_event_status] ([event_status_code], [event_status])
VALUES (10, 'Start')
, (20, 'In-progress')
, (30, 'Finish')
, (40, 'Abort')
;
INSERT INTO [dbo].[tb_event_types] ([event_type_code], [event_type])
VALUES (10, 'Process')
, (20, 'Trigger')
, (30, 'Response')
;
INSERT INTO [dbo].[tb_organisation_categories] ([organisation_category_code], [organisation_category])
VALUES (1, 'Prospect')
, (2, 'Customer')
, (3, 'Internal')
, (4, 'Supplier')
, (5, 'Customer/Supplier')
, (6, 'Partner')
, (7, 'Government')
, (8, 'Logistics')
;
INSERT INTO [dbo].[tb_organisation_hold_status] ([hold_status_code], [hold_status])
VALUES (1, 'OKAY')
, (2, 'ON-HOLD')
, (3, 'ON-STOP')
;
INSERT INTO [dbo].[tb_organisation_sector_codes] ([sector_code], [sector_description])
VALUES ('FOOD', 'Food Industry')
, ('GENENG', 'General Engineering')
, ('MOTOR', 'Automobile Manufacturers')
, ('OVENS', 'Industrial Ovens')
, ('PLASTIC', 'Plastic Mouldings')
, ('PUMPS', 'Pump Manufacturers')
, ('SUB', 'Subcontract Machining')
, ('UNKNOWN', 'Unknown Sector')
;
INSERT INTO [dbo].[tb_organisation_sources] ([organisation_source_id], [organisation_source])
VALUES (5, 'Maishot')
, (6, 'Referal')
, (7, 'CIM Show 2000')
, (8, 'RBS')
, (9, 'Cim Services')
, (10, 'Sarah Purchase')
, (11, 'MCS October Ad')
, (12, 'MCS November Ad')
, (13, 'CIM Show Guide Ad')
, (14, 'Business Solutions')
, (15, 'Innovation 2000')
, (16, 'Web Site')
, (17, 'IT Showcase - Reading')
, (18, 'MCS December Ad')
, (19, 'MCS February Ad')
, (20, 'MCS Ad')
, (21, 'Business Link')
, (22, 'Spotlight Production control')
, (23, 'Cabsoft')
, (24, 'Manufacturing Breakfast')
, (25, 'Yellow Pages')
, (26, 'Gibby')
, (27, 'CIM Show 2001')
, (28, 'Unknown')
;
INSERT INTO [dbo].[tb_organisation_status] ([organisation_status_code], [organisation_status])
VALUES (1, 'Live')
, (2, 'Dead')
, (3, 'Lost Business')
, (4, 'A')
, (5, 'B')
, (6, 'C')
, (7, 'U')
;
INSERT INTO [dbo].[tb_payment_status] ([payment_status_code], [payment_status])
VALUES (10, 'no charge')
, (20, 'on completion')
, (30, 'immediate')
, (40, 'to be agreed')
, (50, 'charged')
, (60, 'partially paid')
, (70, 'fully paid')
;
INSERT INTO [dbo].[tb_people_role_types] ([role_code], [role_description])
VALUES (1, 'Shipments')
, (2, 'Licences')
, (3, 'Literature')
;
INSERT INTO [dbo].[tb_people_titles] ([title])
VALUES ('.')
, ('Dr')
, ('Miss')
, ('Mr')
, ('Mrs')
, ('Ms')
, ('Prof')
;
INSERT INTO [dbo].[tb_resource_skill_classes] ([skill_class_code], [skill_class_description], [skill_class_notes])
VALUES ('Admin', 'Admin', '')
, ('AdminTrainer', 'Admin Trainer', '')
, ('Developer', 'Developer', '')
, ('Novice', 'Novice', '')
, ('User', 'User', '')
, ('UserAdmin', 'User and Admin', '')
, ('UserTrainer', 'User Trainer', '')
;
INSERT INTO [dbo].[tb_supply_status] ([supply_status_code], [supply_status])
VALUES (1, 'Proposed')
, (2, 'Issued')
, (3, 'In Progress')
, (4, 'Complete')
, (5, 'On-hand')
, (6, 'Consumed')
;
INSERT INTO [dbo].[tb_supply_types] ([supply_type_code], [supply_type])
VALUES (1, 'Concept')
, (2, 'On the fly')
;
INSERT INTO [dbo].[tb_tax_rates] ([tax_code], [tax_rate])
VALUES ('STD', 0.175)
, ('ZERO', 0)
;
