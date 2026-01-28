/**
 * Date helper utilities for Vietnam timezone (UTC+7)
 * Ensures consistent date handling across the application
 */

/**
 * Get current date in Vietnam timezone (UTC+7) in YYYY-MM-DD format
 * This should be used instead of new Date().toISOString().split('T')[0]
 * @returns {string} Date string in YYYY-MM-DD format (Vietnam timezone)
 */
function getVietnamDate() {
  return new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Ho_Chi_Minh' });
}

/**
 * Get Vietnam date for a specific date object
 * @param {Date} date - Date object to convert
 * @returns {string} Date string in YYYY-MM-DD format (Vietnam timezone)
 */
function toVietnamDate(date) {
  if (!date) return getVietnamDate();
  return new Date(date).toLocaleDateString('sv-SE', { timeZone: 'Asia/Ho_Chi_Minh' });
}

/**
 * SQL query fragment to get current date in Vietnam timezone
 * Use this in PostgreSQL queries instead of CURRENT_DATE
 * @returns {string} SQL fragment
 */
function vietnamDateSQL() {
  return "(CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date";
}

/**
 * SQL query fragment to convert a timestamp column to Vietnam timezone date
 * @param {string} columnName - Name of the timestamp column
 * @returns {string} SQL fragment
 */
function toVietnamDateSQL(columnName) {
  return `(${columnName} AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date`;
}

/**
 * SQL query fragment to convert a timestamp column to Vietnam timezone datetime
 * @param {string} columnName - Name of the timestamp column
 * @returns {string} SQL fragment
 */
function toVietnamTimestampSQL(columnName) {
  return `(${columnName} AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')`;
}

/**
 * Convert a timestamp from database (UTC) to Vietnam timezone ISO string
 * @param {Date|string} timestamp - Timestamp from database
 * @returns {string} ISO string in Vietnam timezone
 */
function toVietnamTimestampISO(timestamp) {
  if (!timestamp) return null;
  const date = new Date(timestamp);
  // Convert to Vietnam timezone (UTC+7)
  const vnOffset = 7 * 60; // 7 hours in minutes
  const utc = date.getTime() + (date.getTimezoneOffset() * 60000);
  const vnTime = new Date(utc + (vnOffset * 60000));
  return vnTime.toISOString();
}

/**
 * Convert timestamp object to Vietnam timezone for display
 * Handles both Date objects and ISO strings
 * @param {Date|string} timestamp - Timestamp to convert
 * @returns {Date} Date object adjusted to Vietnam timezone
 */
function toVietnamTime(timestamp) {
  if (!timestamp) return null;
  const date = new Date(timestamp);
  // PostgreSQL returns UTC timestamps, we need to display in VN time
  // Since client will handle display, we just ensure it's treated as UTC
  return date;
}

/**
 * Format timestamp to ISO string with Vietnam timezone (+07:00)
 * This ensures Flutter can parse it correctly
 * @param {Date|string} timestamp - Timestamp to format
 * @returns {string} ISO string with +07:00 timezone
 */
function formatVietnamTimestampISO(timestamp) {
  if (!timestamp) return null;
  const date = timestamp instanceof Date ? timestamp : new Date(timestamp);
  
  // Convert to Vietnam timezone (UTC+7)
  const vnTime = new Date(date.getTime() + (7 * 60 * 60 * 1000));
  
  // Format as ISO with timezone indicator
  const year = vnTime.getUTCFullYear();
  const month = String(vnTime.getUTCMonth() + 1).padStart(2, '0');
  const day = String(vnTime.getUTCDate()).padStart(2, '0');
  const hours = String(vnTime.getUTCHours()).padStart(2, '0');
  const minutes = String(vnTime.getUTCMinutes()).padStart(2, '0');
  const seconds = String(vnTime.getUTCSeconds()).padStart(2, '0');
  const ms = String(vnTime.getUTCMilliseconds()).padStart(3, '0');
  
  return `${year}-${month}-${day}T${hours}:${minutes}:${seconds}.${ms}+07:00`;
}

module.exports = {
  getVietnamDate,
  toVietnamDate,
  vietnamDateSQL,
  toVietnamDateSQL,
  toVietnamTimestampSQL,
  toVietnamTimestampISO,
  toVietnamTime,
  formatVietnamTimestampISO
};
