# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2023, by Samuel Williams.

require_relative 'version'

module Async
	module WebDriver
		class Error < StandardError
		end

		# The Element Click command could not be completed because the element receiving the events is obscuring the element that was requested clicked.
		class ElementClickInterceptedError < Error
			CODE = "element click intercepted"
		end

		# A command could not be completed because the element is not pointer- or keyboard interactable.
		class ElementNotInteractableError < Error
			CODE = "element not interactable"
		end

		# Navigation caused the user agent to hit a certificate warning, which is usually the result of an expired or invalid TLS certificate.
		class InsecureCertificateError < Error
			CODE = "insecure certificate"
		end

		# The arguments passed to a command are either invalid or malformed.
		class InvalidArgumentError < Error
			CODE = "invalid argument"
		end

		# An illegal attempt was made to set a cookie under a different domain than the current page.
		class InvalidCookieDomainError < Error
			CODE = "invalid cookie domain"
		end

		# A command could not be completed because the element is in an invalid state, e.g. attempting to clear an element that isn’t both editable and resettable.
		class InvalidElementStateError < Error
			CODE = "invalid element state"
		end

		# Argument was an invalid selector.
		class InvalidSelectorError < Error
			CODE = "invalid selector"
		end

		# Occurs if the given session id is not in the list of active sessions, meaning the session either does not exist or that it’s not active.
		class InvalidSessionIdError < Error
			CODE = "invalid session id"
		end

		# An error occurred while executing JavaScript supplied by the user.
		class JavaScriptError < Error
			CODE = "javascript error"
		end

		# The target for mouse interaction is not in the browser’s viewport and cannot be brought into that viewport.
		class MoveTargetOutOfBoundsError < Error
			CODE = "move target out of bounds"
		end

		# An attempt was made to operate on a modal dialog when one was not open.
		class NoSuchAlertError < Error
			CODE = "no such alert"
		end

		# No cookie matching the given path name was found amongst the associated cookies of the current browsing context’s active document.
		class NoSuchCookieError < Error
			CODE = "no such cookie"
		end

		# An element could not be located on the page using the given search parameters.
		class NoSuchElementError < Error
			CODE = "no such element"
		end

		# A command to switch to a frame could not be satisfied because the frame could not be found.
		class NoSuchFrameError < Error
			CODE = "no such frame"
		end

		# A command to switch to a window could not be satisfied because the window could not be found.
		class NoSuchWindowError < Error
			CODE = "no such window"
		end

		# The element does not have a shadow root.
		class NoSuchShadowRootError < Error
			CODE = "no such shadow root"
		end

		# A script did not complete before its timeout expired.
		class ScriptTimeoutError < Error
			CODE = "script timeout error"
		end

		# A new session could not be created.
		class SessionNotCreatedError < Error
			CODE = "session not created"
		end

		# A command failed because the referenced element is no longer attached to the DOM.
		class StaleElementReferenceError < Error
			CODE = "stale element reference"
		end

		# A command failed because the referenced shadow root is no longer attached to the DOM.
		class DetachedShadowRootError < Error
			CODE = "detached shadow root"
		end

		# An operation did not complete before its timeout expired.
		class TimeoutError < Error
			CODE = "timeout"
		end

		# A command to set a cookie’s value could not be satisfied.
		class UnableToSetCookieError < Error
			CODE = "unable to set cookie"
		end

		# A screen capture was made impossible.
		class UnableToCaptureScreenError < Error
			CODE = "unable to capture screen"
		end

		# A modal dialog was open, blocking this operation.
		class UnexpectedAlertOpenError < Error
			CODE = "unexpected alert open"
		end

		# A command could not be executed because the remote end is not aware of it.
		class UnknownCommandError < Error
			CODE = "unknown command"
		end

		# An unknown error occurred in the remote end while processing the command.
		class UnknownError < Error
			CODE = "unknown error"
		end

		# The requested command matched a known URL but did not match any method for that URL.
		class UnknownMethodError < Error
			CODE = "unknown method"
		end

		# Indicates that a command that should have executed properly cannot be supported for some reason.
		class UnsupportedOperationError < Error
			CODE = "unsupported operation"
		end

		ERROR_CODES = {
			ElementClickInterceptedError::CODE => ElementClickInterceptedError,
			ElementNotInteractableError::CODE => ElementNotInteractableError,
			InsecureCertificateError::CODE => InsecureCertificateError,
			InvalidArgumentError::CODE => InvalidArgumentError,
			InvalidCookieDomainError::CODE => InvalidCookieDomainError,
			InvalidElementStateError::CODE => InvalidElementStateError,
			InvalidSelectorError::CODE => InvalidSelectorError,
			InvalidSessionIdError::CODE => InvalidSessionIdError,
			JavaScriptError::CODE => JavaScriptError,
			MoveTargetOutOfBoundsError::CODE => MoveTargetOutOfBoundsError,
			NoSuchAlertError::CODE => NoSuchAlertError,
			NoSuchCookieError::CODE => NoSuchCookieError,
			NoSuchElementError::CODE => NoSuchElementError,
			NoSuchFrameError::CODE => NoSuchFrameError,
			NoSuchWindowError::CODE => NoSuchWindowError,
			NoSuchShadowRootError::CODE => NoSuchShadowRootError,
			ScriptTimeoutError::CODE => ScriptTimeoutError,
			SessionNotCreatedError::CODE => SessionNotCreatedError,
			StaleElementReferenceError::CODE => StaleElementReferenceError,
			DetachedShadowRootError::CODE => DetachedShadowRootError,
			TimeoutError::CODE => TimeoutError,
			UnableToSetCookieError::CODE => UnableToSetCookieError,
			UnableToCaptureScreenError::CODE => UnableToCaptureScreenError,
			UnexpectedAlertOpenError::CODE => UnexpectedAlertOpenError,
			UnknownCommandError::CODE => UnknownCommandError,
			UnknownError::CODE => UnknownError,
			UnknownMethodError::CODE => UnknownMethodError,
			UnsupportedOperationError::CODE => UnsupportedOperationError,
		}
	end
end
