const bodyMeasurementService = require('../services/bodyMeasurementService');

const bodyMeasurementController = {
  /**
   * GET /body-measurement/latest
   * Get latest body measurement for authenticated user
   */
  async getLatest(req, res) {
    try {
      const userId = req.user?.user_id;
      
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const measurement = await bodyMeasurementService.getLatestMeasurement(userId);
      
      if (!measurement) {
        return res.status(404).json({
          success: false,
          message: 'No measurements found'
        });
      }

      res.json({
        success: true,
        measurement
      });
    } catch (error) {
      console.error('Error getting latest measurement:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get measurement',
        error: error.message
      });
    }
  },

  /**
   * GET /body-measurement/history
   * Get measurement history
   */
  async getHistory(req, res) {
    try {
      const userId = req.user?.user_id;
      const limit = parseInt(req.query.limit) || 30;
      
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const history = await bodyMeasurementService.getMeasurementHistory(userId, limit);
      
      res.json({
        success: true,
        history,
        count: history.length
      });
    } catch (error) {
      console.error('Error getting measurement history:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get history',
        error: error.message
      });
    }
  },

  /**
   * POST /body-measurement
   * Add new measurement
   */
  async addMeasurement(req, res) {
    try {
      const userId = req.user?.user_id;
      const { weight_kg, height_cm, source, notes } = req.body;
      
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      if (!weight_kg || !height_cm) {
        return res.status(400).json({
          success: false,
          message: 'Weight and height are required'
        });
      }

      const measurement = await bodyMeasurementService.addMeasurement(userId, {
        weight_kg: parseFloat(weight_kg),
        height_cm: parseFloat(height_cm),
        source,
        notes
      });

      res.status(201).json({
        success: true,
        measurement
      });
    } catch (error) {
      console.error('Error adding measurement:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to add measurement',
        error: error.message
      });
    }
  },

  /**
   * GET /body-measurement/statistics
   * Get BMI statistics and trends
   */
  async getStatistics(req, res) {
    try {
      const userId = req.user?.user_id;
      
      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'Unauthorized'
        });
      }

      const stats = await bodyMeasurementService.getBMIStatistics(userId);
      
      res.json({
        success: true,
        statistics: stats
      });
    } catch (error) {
      console.error('Error getting statistics:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get statistics',
        error: error.message
      });
    }
  },
};

module.exports = bodyMeasurementController;
