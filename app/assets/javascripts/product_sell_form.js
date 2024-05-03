$(document).on('turbo:load', function() {
  var productSearchInput = document.getElementById('product_search_input');
  var products = document.querySelectorAll('.product_list');
  let activeIndex = -1;

  function setActive(index) {
    products.forEach((product, i) => {
      if (i === index) {
        product.classList.add('active');
        product.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      } else {
        product.classList.remove('active');
      }
    });
  }

  function handleClick(index) {
    if (index >= 0 && index < products.length) {
      products[index].dispatchEvent(new Event('click'));
    }
  }

  document.getElementById('product_search_input').addEventListener('input', function() {
    const searchTerm = productSearchInput.value.toLowerCase();
    const selectedCategoryId = $('.category-row.active-category').data('category-id');

    products.forEach(function(product) {
      if (window.getComputedStyle(product).display !== 'none') {
        const productName = product.dataset.productName.toLowerCase();
        let displayStyle = 'none'; // Default: hide the product

        if (productName.includes(searchTerm)) {
          displayStyle = 'revert'; // Show the product if it starts with the search term
        }
        product.style.display = displayStyle;
      }
    });

    setActive(-1);
    activeIndex = -1;
  });

  document.addEventListener('keydown', function(event) {
    if (document.activeElement.id === 'product_sell_amount') {
      return;
    }

    if (event.key === 'ArrowUp' || event.key === 'ArrowDown') {
      event.preventDefault();

      let newIndex;
      if (event.key === 'ArrowUp') {
        newIndex = activeIndex <= 0 ? products.length - 1 : activeIndex - 1;
      } else {
        newIndex = activeIndex >= products.length - 1 ? 0 : activeIndex + 1;
      }

      while (products[newIndex].style.display === 'none') {
        if (event.key === 'ArrowUp') {
          newIndex = newIndex <= 0 ? products.length - 1 : newIndex - 1;
        } else {
          newIndex = newIndex >= products.length - 1 ? 0 : newIndex + 1;
        }
      }
      setActive(newIndex);
      activeIndex = newIndex;
      handleClick(newIndex);
    }
  });

  $(document).on('keypress', function(event) {
    if ($('.product_list.active').length && event.key === 'Enter') {
      $('#product_sell_amount').focus();
    }
  });

  // Function to handle product filtering based on category and input value
  function filterProducts() {
    const searchTerm = productSearchInput.value.toLowerCase();
    const selectedCategoryId = $('.category-row.active-category').data('category-id');

    products.forEach(function(product) {
      const productName = product.dataset.productName.toLowerCase();
      const productCategoryId = product.dataset.categoryId;

      // Check if the product name includes the search term and if it belongs to the selected category
      if ((productName.includes(searchTerm) || searchTerm === '') &&
          (selectedCategoryId === undefined || productCategoryId == selectedCategoryId)) {
        product.style.display = 'revert'; // Show the product
      } else {
        product.style.display = 'none'; // Hide the product
      }
    });
  }

  // Event listener for input event (typing and backspace)
  productSearchInput.addEventListener('input', filterProducts);

  // Event listener for backspace key press
  productSearchInput.addEventListener('keydown', function(event) {
    if (event.key === 'Backspace') {
      // Call the filterProducts function when the backspace key is pressed
      filterProducts();
    }
  });
});
