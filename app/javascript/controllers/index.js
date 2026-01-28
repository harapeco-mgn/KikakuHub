import { application } from "controllers/application"
import AutoDismissController from "controllers/auto_dismiss_controller"
import SecondaryButtonController from "controllers/secondary_button_controller"
import AvailabilityDraftController from "controllers/availability_draft_controller"
import AvailabilitySlotsController from "controllers/availability_slots_controller"
import AutoSubmitController from "controllers/auto_submit_controller"

application.register("auto-dismiss", AutoDismissController)
application.register("secondary-button", SecondaryButtonController)
application.register("availability-draft", AvailabilityDraftController)
application.register("availability-slots", AvailabilitySlotsController)
application.register("auto-submit", AutoSubmitController)
