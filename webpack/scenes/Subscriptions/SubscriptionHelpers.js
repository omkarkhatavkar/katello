// eslint-disable-next-line import/prefer-default-export
export const filterRHSubscriptions = subscriptions =>
  subscriptions.filter(sub => sub.available >= 0);

export const manifestExists = organization =>
  organization.owner_details && organization.owner_details.upstreamConsumer;
