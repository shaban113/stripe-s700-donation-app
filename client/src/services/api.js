import axios from 'axios';

// Use a relative path for production (same domain), or set your full production API URL here:
const API_BASE_URL = '/api'; // For example, https://yourdomain.com/api if your backend is at /api

export const submitDonation = async (amount) => {
  try {
    const response = await axios.post(`${API_BASE_URL}/donations`, { amount });
    return response.data;
  } catch (error) {
    throw new Error(error.response ? error.response.data.message : 'Error submitting donation');
  }
};

export const getPaymentStatus = async (paymentIntentId) => {
  try {
    const response = await axios.get(`${API_BASE_URL}/payments/${paymentIntentId}`);
    return response.data;
  } catch (error) {
    throw new Error(error.response ? error.response.data.message : 'Error retrieving payment status');
  }
};