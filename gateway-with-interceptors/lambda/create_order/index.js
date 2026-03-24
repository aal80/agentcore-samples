const menu = [
  { id: 1, name: "Margherita", price: 12.99 },
  { id: 2, name: "Pepperoni", price: 14.99 },
  { id: 3, name: "Four Cheese", price: 15.99 },
  { id: 4, name: "BBQ Chicken", price: 16.99 },
  { id: 5, name: "Hawaiian", price: 15.49 },
  { id: 6, name: "Veggie Supreme", price: 14.99 },
];

exports.handler = async (event) => {
  console.log({event});
  const itemIds = event.itemIds;

    if (!Array.isArray(itemIds) || itemIds.length === 0) {
    return { error: "itemIds must be a non-empty array of pizza IDs" };
  }

  const matched = itemIds
    .map((id) => menu.find((p) => p.id === id))
    .filter(Boolean);

  const total = matched.reduce((sum, p) => sum + p.price, 0);

  return {
    date: new Date().toISOString(),
    items: matched.map((p) => p.name).join(", "),
    total: Math.round(total * 100) / 100,
  };
};
