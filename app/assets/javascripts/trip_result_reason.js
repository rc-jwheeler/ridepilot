// JS for modal handling trip cancellation reason inputs

// takes a jQuery selector identifying the trip result reason modal div,
// and an array of codes (id #s) to consider "Cancellations"
function TripResultHelper(modalSelector, cancelCodes) {
  this.modal = $(modalSelector);
  this.cancelCodes = cancelCodes;
  this.tripForm = null;
}

TripResultHelper.prototype = {
  // Sets up the helper to deal with a change on a particular trip
  processChange: function(element) {
    this.tripForm = {
      form: element.closest('form'),
      input: element.closest('form').find('input#trip_result_reason'),
      resultCode: parseInt(element.val())
    }
  },

  isCancelCodeSelected: function() {
    return this.cancelCodes.includes(this.tripForm.resultCode);
  },

  showResultReasonModal: function() {
    this.prepareModal();
    this.modal.modal('show');
  },

  prepareModal: function() {
    var modalInput = this.modal.find('.result-reason-text');
    var trh = this;

    // Update modal input to existing value of reason result
    modalInput.val(this.tripForm.input.val());

    // On modal submit, update form text input based on modal input
    this.modal.find('.submit-result-reason').click(function() {
      trh.tripForm.input.val(modalInput.val());
      trh.tripForm.form.submit();
    });

    // On modal dismiss, discard the modal text input
    this.modal.find('.dismiss-result-reason').click(function() {
      trh.tripForm.form.submit();
    });

  }

}
