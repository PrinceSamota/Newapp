document.addEventListener("DOMContentLoaded", function () {
    const addItemBtn = document.getElementById("add-item");
    const template = document.getElementById("item-template").innerHTML;
    const itemsContainer = document.getElementById("items");
  
    let index = 1; // Start from 1 because 0 is already rendered by Rails
  
    addItemBtn.addEventListener("click", function () {
      const newItemHTML = template.replace(/INDEX/g, index);
      const wrapper = document.createElement("div");
      wrapper.innerHTML = newItemHTML;
      itemsContainer.appendChild(wrapper);
      index++;
    });
  });
  