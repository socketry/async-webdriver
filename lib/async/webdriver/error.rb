# frozen_string_literal: true

require_relative 'version'

module Async
	module WebDriver
		class Error < StandardError
		end

		class ElementClickInterceptedError < Error
			CODE = "element click intercepted"
		end

		class ElementNotInteractableError < Error
			CODE = "element not interactable"
		end

		class InsecureCertificateError < Error
			CODE = "insecure certificate"
		end

		class InvalidArgumentError < Error
			CODE = "invalid argument"
		end

		class InvalidCookieDomainError < Error
			CODE = "invalid cookie domain"
		end

		class InvalidElementStateError < Error
			CODE = "invalid element state"
		end

		class InvalidSelectorError < Error
			CODE = "invalid selector"
		end

		class InvalidSessionIdError < Error
			CODE = "invalid session id"
		end

		class JavaScriptError < Error
			CODE = "javascript error"
		end

		class MoveTargetOutOfBoundsError < Error
			CODE = "move target out of bounds"
		end

		class NoSuchAlertError < Error
			CODE = "no such alert"
		end

		class NoSuchCookieError < Error
			CODE = "no such cookie"
		end

		class NoSuchElementError < Error
			CODE = "no such element"
		end

		class NoSuchFrameError < Error
			CODE = "no such frame"
		end

		class NoSuchWindowError < Error
			CODE = "no such window"
		end

		class NoSuchShadowRootError < Error
			CODE = "no such shadow root"
		end

		class ScriptTimeoutError < Error
			CODE = "script timeout error"
		end

		class SessionNotCreatedError < Error
			CODE = "session not created"
		end

		class StaleElementReferenceError < Error
			CODE = "stale element reference"
		end

		class DetachedShadowRootError < Error
			CODE = "detached shadow root"
		end

		class TimeoutError < Error
			CODE = "timeout"
		end

		class UnableToSetCookieError < Error
			CODE = "unable to set cookie"
		end

		class UnableToCaptureScreenError < Error
			CODE = "unable to capture screen"
		end

		class UnexpectedAlertOpenError < Error
			CODE = "unexpected alert open"
		end

		class UnknownCommandError < Error
			CODE = "unknown command"
		end

		class UnknownError < Error
			CODE = "unknown error"
		end

		class UnknownMethodError < Error
			CODE = "unknown method"
		end

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
			UnableToCaptureScreenError::CODE => UnableToCaptureScreenError
		}
	end
end