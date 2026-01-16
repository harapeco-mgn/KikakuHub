import { application } from "controllers/application"
import AutoDismissController from "controllers/auto_dismiss_controller"
import SecondaryButtonController from "controllers/secondary_button_controller"

application.register("auto-dismiss", AutoDismissController)
application.register("secondary-button", SecondaryButtonController)
