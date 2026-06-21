/** Checks if an ID is in the persistent list. */
function isPersistent(id, persistentList) {
  return persistentList.indexOf(id) !== -1;
}

/**
 * Returns special workspaces (ID < 0).
 * Input: Hyprland.workspaces.values
 * Output: Array
 */
function getSpecial(allWorkspaces) {
  var result = [];
  for (var i = 0; i < allWorkspaces.length; i++) {
    var ws = allWorkspaces[i];
    if (ws.id < 0) result.push(ws);
  }
  // Sort by ID to maintain order
  result.sort(function (a, b) {
    return a.id - b.id;
  });
  return result;
}

/**
 * Returns "Other" workspaces (dynamic):
 * Input: Hyprland.workspaces.values, persistentIDs
 */
function getOther(allWorkspaces, persistentList) {
  var result = [];
  for (var i = 0; i < allWorkspaces.length; i++) {
    var ws = allWorkspaces[i];
    // Exclude Persistent
    if (isPersistent(ws.id, persistentList)) continue;
    // Exclude Empty Other
    if (!ws.focused && ws.toplevels.values.length === 0) continue;
    // Exclude Special Workspaces
    if (ws.id < 0) continue;
    result.push(ws);
  }
  // Sort by ID to maintain order
  result.sort(function (a, b) {
    return a.id - b.id;
  });
  return result;
}
