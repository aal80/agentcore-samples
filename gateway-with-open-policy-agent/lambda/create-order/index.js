const menu = [
  { id: 1, name: "Margherita", price: 12.99 },
  { id: 2, name: "Pepperoni", price: 14.99 },
  { id: 3, name: "Four Cheese", price: 15.99 },
  { id: 4, name: "BBQ Chicken", price: 16.99 },
  { id: 5, name: "Pineapple Deluxe", price: 15.49 },
  { id: 6, name: "Veggie Supreme", price: 14.99 },
];

exports.handler = async (event) => {
  console.log({event});
  const pizzaId = event.pizzaId;

  const pizza = menu.find((p) => p.id === pizzaId);
  if (!pizza) {
    return { error: `Pizza with id ${pizzaId} not found` };
  }

  return {
    date: new Date().toISOString(),
    item: pizza.name,
    total: pizza.price,
  };
};
