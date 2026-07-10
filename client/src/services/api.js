import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || '/api';

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