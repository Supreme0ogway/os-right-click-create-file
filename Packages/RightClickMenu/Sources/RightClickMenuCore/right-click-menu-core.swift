/// The one way in to this module.
///
/// Re-exports the floor, so anything importing this module gets the records it works
/// with and never has to reach past it. Nothing else belongs in here: a funnel holds
/// no decisions.

@_exported import RightClickMenuShared
