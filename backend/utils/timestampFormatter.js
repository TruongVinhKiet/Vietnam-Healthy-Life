/**
 * Format timestamp to ensure Flutter client can parse it correctly with VN timezone
 * PostgreSQL AT TIME ZONE returns timestamp without timezone info
 * This function formats it with +07:00 timezone indicator
 */

/**
 * Format a timestamp from database to ISO string with VN timezone
 * @param {Date|string} timestamp - Timestamp from database (may be UTC or converted)
 * @returns {string} ISO string with +07:00 timezone
 */
function formatVietnamTimestamp(timestamp) {
  if (!timestamp) return null;
  
  // If already a Date object, use it; otherwise parse
  const date = timestamp instanceof Date ? timestamp : new Date(timestamp);
  
  // If timestamp is already in VN timezone format (from SQL conversion),
  // we need to format it with timezone indicator
  // Convert to ISO and adjust for VN timezone
  const vnOffsetMs = 7 * 60 * 60 * 1000; // 7 hours in milliseconds
  const utcTime = date.getTime();
  const vnTime = new Date(utcTime + vnOffsetMs);
  
  // Format with timezone indicator
  const iso = vnTime.toISOString();
  // Replace 'Z' with '+07:00' to indicate VN timezone
  return iso.replace('Z', '+07:00');
}

/**
 * Process database result rows and format all timestamp fields
 * @param {Array} rows - Database result rows
 * @param {Array<string>} timestampFields - Field names that contain timestamps
 * @returns {Array} Processed rows with formatted timestamps
 */
function formatTimestampFields(rows, timestampFields = ['created_at', 'updated_at', 'read_at', 'deleted_at']) {
  if (!rows || !Array.isArray(rows)) return rows;
  
  return rows.map(row => {
    const formatted = { ...row };
    timestampFields.forEach(field => {
      if (formatted[field]) {
        formatted[field] = formatVietnamTimestamp(formatted[field]);
      }
    });
    return formatted;
  });
}

module.exports = {
  formatVietnamTimestamp,
  formatTimestampFields
};

