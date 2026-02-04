package comparison_after_resolution

import rego.v1

# Source: https://github.com/ArthurSens/demo-weaver-for-dashboarding/blob/main/semconv/policies/test.rego
# Semantic Convention Registry Compatibility Checker
#
# This file contains rules for checking backward compatibility
# between different versions of semantic convention registries.
# It builds upon the data structures and rules defined in the
# semconv package.

# Import the previous release (baseline) and current sets of attributes, metrics.
baseline_attributes := [attr |
    some g in data.semconv.registry_baseline_groups
    some attr in g.attributes
]
registry_attributes := [attr |
    some g in data.semconv.registry_groups
    some attr in g.attributes
]
registry_attribute_names := {attr.name |
    some g in data.semconv.registry_groups
    some attr in g.attributes
}
baseline_metrics := [ g |
    some g in data.semconv.baseline_groups
    g.type == "metric"
]
registry_metrics := [ g |
    some g in data.semconv.groups
    g.type == "metric"
]
registry_metric_names := { g.metric_name | some g in registry_metrics }

baseline_resources := [ g |
    some g in data.semconv.baseline_groups
    g.type == "resource"
]
registry_resources := [g |
    some g in data.semconv.groups
    g.type == "resource"
]
registry_resource_names := { g.name | some g in registry_resources }

baseline_events := [ g |
    some g in data.semconv.baseline_groups
    g.type == "event"
]
registry_events := [g |
    some g in data.semconv.groups
    g.type == "event"
]
registry_event_names := { g.name | some g in registry_events }

# Rules we enforce:
# - Attributes
#   - [x] Attributes cannot be removed
#   - [x] Attributes cannot "degrade" stability (stable->experimental)
#   - [x] Stable attributes cannot change type
#   - Enum members
#     - [x] Stable members cannot change stability
#     - [x] Values cannot change
#     - [x] ids cannot be removed
# - Metrics
#   - [x] metrics cannot be removed
#   - [x] Stable metrics cannot become unstable
#   - [x] Stable Metric units cannot change
#   - [x] Stable Metric instruments cannot change
#   - [x] Set of required/recommended attributes must remain the same
# - Resources
#   - [x] resources cannot be removed
#   - [x] Stable Resources cannot become unstable
#   - [x] Stable attributes cannot be dropped from stable resource
# - Events
#   - [x] events cannot be removed
#   - [x] Stable events cannot become unstable
#   - [x] Stable attributes cannot be dropped from stable event
# - Spans - no enforcement yet since id format is not finalized
#   - [ ] spans cannot be removed
#   - [ ] Stable spans cannot become unstable
#   - [ ] Stable attributes cannot be dropped from stable span

# Rule: Detect Removed Attributes
#
# This rule checks for attributes that existed in the baseline registry
# but are no longer present in the current registry. Removing attributes
# is considered a backward compatibility violation.
#
# In other words, we do not allow the removal of an attribute once added
# to the registry. It must exist SOMEWHERE in a group, but may be deprecated.
deny contains back_comp_violation(description, group_id, attr.name) if {
    # Check if an attribute from the baseline is missing in the current registry
    some attr in baseline_attributes
    not registry_attribute_names[attr.name]

    # Generate human readable error.
    group_id := data.semconv.baseline_group_ids_by_attribute[attr.name]
    description := sprintf("Attribute '%s' no longer exists in the attribute registry", [attr.name])
}

# Rule: Detect Stable Attributes moving to unstable
#
# This rule checks for attributes that were stable in the baseline registry
# but are no longer stable in the current registry. Once stable, attributes
# remain forever but may be deprecated.
deny contains back_comp_violation(description, group_id, attr.name) if {
     # Find stable baseline attributes in latest registry.
     some attr in baseline_attributes
     attr.stability == "stable"
     some nattr in registry_attributes
     attr.name == nattr.name

     # Enforce the policy
     attr.stability != nattr.stability

     # Generate human readable error.
     group_id := data.semconv.baseline_group_ids_by_attribute[attr.name]
     description := sprintf("Attribute '%s' was stable, but has new stability marker", [attr.name])
}
# Rule: Stable attributes on stable metric cannot be dropped.
#
# This rule checks that stable metrics have stable sets of attributes.
deny contains back_comp_violation(description, group_id, "") if {
    # Find data we need to enforce
    some metric in baseline_metrics
    metric.stability == "stable"
    some nmetric in registry_metrics
    metric.metric_name = nmetric.metric_name

    baseline_attributes := { attr.name |
        some attr in metric.attributes
        attr.stability == "stable"
    }
    new_attributes := { attr.name |
        some attr in nmetric.attributes
        attr.stability == "stable"
    }
    missing_attributes := baseline_attributes - new_attributes
    # Enforce the policy
    count(missing_attributes) > 0

    # Generate human readable error.
    group_id := metric.id
    description := sprintf("Metric '%s' cannot change required/recommended attributes (missing '%s')", [metric.metric_name, missing_attributes])
}




# Helper Function: Create Backward Compatibility Violation Object
#
# This function generates a structured violation object for each
# detected backward compatibility issue.
back_comp_violation(description, group_id, attr_id) := violation if {
    violation := {
        "id": description,
        "type": "semconv_attribute",
        "category": "backward_compatibility",
        "group": group_id,
        "attr": attr_id,
    }
}

# Helpers for enum values and type strings
is_enum(attr) := true if count(attr.type.members) > 0
type_string(attr) := attr.type if not is_enum(attr)
type_string(attr) := "enum" if is_enum(attr)
is_opt_in(attr) := true if attr.requirement_level == "opt_in"
