export function formatCurrency(amount) {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  }).format(amount / 100);
}

export function formatDonationMessage(amount) {
  return `Thank you for your generous donation of ${formatCurrency(amount)}!`;
}

export function formatPaymentStatus(isSuccess) {
  return isSuccess ? 'Payment Successful!' : 'Payment Failed. Please try again.';
}