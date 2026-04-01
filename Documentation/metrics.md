# Produced Metrics


## Metric `warehouse.conveyor.processed.total`

| Name     | Instrument Type | Unit (UCUM) | Description    | Stability |
| -------- | --------------- | ----------- | -------------- | --------- |
| `warehouse.conveyor.processed.total` | Counter | `{item}` | Total number of items processed by the conveyor | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |


### `warehouse.conveyor.processed.total` Attributes

| Attribute  | Type | Description  | Examples  | [Requirement Level](https://opentelemetry.io/docs/specs/semconv/general/attribute-requirement-level/) | Stability |
|---|---|---|---|---|---|
| `warehouse.conveyor.id` | string | The conveyor unique identifier. | `CentralConveyor1` | `Required` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `warehouse.item.type` | string | The type of item to be stored | `Box`; `Pallet`; `Envelope` | `Required` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `warehouse.conveyor.error` | string | The conveyor operation error | `Obstacle`; `Pneumatics failure` | `Recommended` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `warehouse.conveyor.operator_id` | string | The operator supervising the conveyor unique identifier. | `Operators_John_Doe` | `Opt-In` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |

---

`warehouse.item.type` has the following list of well-known values. If one of them applies, then the respective value MUST be used; otherwise, a custom value MAY be used.

| Value  | Description | Stability |
|---|---|---|
| `Box` | box | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `Envelope` | envelope | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `Pallet` | pallet | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `Unknown` | Unknown | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |



## Metric `warehouse.conveyor.active`

| Name     | Instrument Type | Unit (UCUM) | Description    | Stability |
| -------- | --------------- | ----------- | -------------- | --------- |
| `warehouse.conveyor.active` | Gauge | `{conveyor}` | Number of conveyors currently active | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |


### `warehouse.conveyor.active` Attributes

| Attribute  | Type | Description  | Examples  | [Requirement Level](https://opentelemetry.io/docs/specs/semconv/general/attribute-requirement-level/) | Stability |
|---|---|---|---|---|---|
| `warehouse.conveyor.id` | string | The conveyor unique identifier. | `CentralConveyor1` | `Recommended` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |
| `warehouse.conveyor.operator_id` | string | The operator supervising the conveyor unique identifier. | `Operators_John_Doe` | `Opt-In` | ![Stable](https://img.shields.io/badge/-stable-lightgreen) |


