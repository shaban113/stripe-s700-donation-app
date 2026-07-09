import { loadStripe } from '@stripe/stripe-js';

const stripePromise = loadStripe('your-publishable-key-here');

export const createPaymentIntent = async (amount) => {
  const response = await fetch('/api/payment_intents', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ amount }),
  });

  if (!response.ok) {
    throw new Error('Failed to create payment intent');
  }

  return response.json();
};

export const processPayment = async (paymentIntentId, readerId) => {
  const response = await fetch(`/api/process_payment`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ paymentIntentId, readerId }),
  });

  if (!response.ok) {
    throw new Error('Failed to process payment');
  }

  return response.json();
};

export const getPaymentStatus = async (paymentIntentId) => {
  const response = await fetch(`/api/payment_status/${paymentIntentId}`);

  if (!response.ok) {
    throw new Error('Failed to retrieve payment status');
  }

  return response.json();
};