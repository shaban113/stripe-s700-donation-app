import { loadStripe } from '@stripe/stripe-js';

const publishableKey = process.env.REACT_APP_STRIPE_PUBLISHABLE_KEY || (typeof window !== 'undefined' ? window.__STRIPE_PUBLISHABLE_KEY__ : undefined);

if (!publishableKey) {
  throw new Error('Missing Stripe publishable key. Set REACT_APP_STRIPE_PUBLISHABLE_KEY for the frontend build.');
}

const stripePromise = loadStripe(publishableKey);

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