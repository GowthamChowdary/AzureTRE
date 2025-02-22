import logging
import os
import re

from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.trace import config_integration
from opencensus.trace.samplers import AlwaysOnSampler
from opencensus.trace.tracer import Tracer

UNWANTED_LOGGERS = [
    "azure.core.pipeline.policies.http_logging_policy",
    "azure.eventhub._eventprocessor.event_processor",
    "azure.identity.aio._credentials.managed_identity",
    "azure.identity.aio._credentials.environment",
    "azure.identity.aio._internal.get_token_mixin",
    "azure.identity.aio._internal.decorators",
    "azure.identity.aio._credentials.chained",
    "azure.identity",
    "msal.token_cache",
    "uamqp",
    "uamqp.authentication.cbs_auth_async",
    "uamqp.async_ops.client_async",
    "uamqp.async_ops.connection_async",
    "uamqp.async_ops",
    "uamqp.authentication",
    "uamqp.c_uamqp",
    "uamqp.connection",
    "uamqp.receiver"
]


def disable_unwanted_loggers():
    """
    Disables the unwanted loggers.
    """
    for logger_name in UNWANTED_LOGGERS:
        logging.getLogger(logger_name).disabled = True


def initialize_logging(logging_level: int, correlation_id: str) -> logging.LoggerAdapter:
    """
    Adds the Application Insights handler for the root logger and sets the given logging level.
    Creates and returns a logger adapter that integrates the correlation ID, if given, to the log messages.
    Note: This should be called only once, otherwise duplicate log entries could be produced.

    :param logging_level: The logging level to set e.g., logging.WARNING.
    :param correlation_id: Optional. The correlation ID that is passed on to the operation_Id in App Insights.
    :returns: A newly created logger adapter.
    """
    logger = logging.getLogger()
    logger.addHandler(logging.StreamHandler())  # For logging into console
    app_insights_connection_string = os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING")

    try:
        logger.addHandler(AzureLogHandler(connection_string=app_insights_connection_string))
    except ValueError as e:
        logger.error(f"Failed to set Application Insights logger handler: {e}")

    config_integration.trace_integrations(['logging'])
    logging.basicConfig(level=logging_level, format='%(asctime)s traceId=%(traceId)s spanId=%(spanId)s %(message)s')
    Tracer(sampler=AlwaysOnSampler())
    logger.setLevel(logging_level)

    extra = None

    if correlation_id:
        extra = {'traceId': correlation_id}

    adapter = logging.LoggerAdapter(logger, extra)
    adapter.debug(f"Logger adapter initialized with extra: {extra}")

    return adapter


def get_message_id_logger(correlation_id: str) -> logging.LoggerAdapter:
    """
    Gets a logger that includes message id for easy correlation between log entries.
    :param correlation_id: Optional. The correlation ID that is passed on to the operation_Id in App Insights.
    :returns: A modified logger adapter (from the original initiated one).
    """
    logger = logging.getLogger()
    extra = None

    if correlation_id:
        extra = {'traceId': correlation_id}

    adapter = logging.LoggerAdapter(logger, extra)
    adapter.debug(f"Logger adapter now includes extra: {extra}")

    return adapter


def shell_output_logger(console_output: str, prefix_item: str, logger: logging.LoggerAdapter, logging_level: int):
    """
    Logs the shell output (stdout/err) a line at a time with an option to remove ANSI control chars.
    """
    logger.log(logging_level, prefix_item)

    if console_output is None:
        return

    # 7-bit C1 ANSI sequences
    ansi_escape = re.compile(r'''
        \x1B  # ESC
        (?:   # 7-bit C1 Fe (except CSI)
            [@-Z\\-_]
        |     # or [ for CSI, followed by a control sequence
            \[
            [0-?]*  # Parameter bytes
            [ -/]*  # Intermediate bytes
            [@-~]   # Final byte
        )
    ''', re.VERBOSE)

    for string in console_output.split('\n'):
        if os.environ.get('DEBUG', False) is False:
            string = ansi_escape.sub('', string)  # removes all ANSI formatting

        if len(string) != 0:
            logger.log(logging_level, string)
