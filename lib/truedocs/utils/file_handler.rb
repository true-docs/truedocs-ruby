# frozen_string_literal: true

require "marcel"
require "stringio"
require "pathname"

module Truedocs
  module Utils
    # Handles file operations and validations for document processing.
    # This class is responsible for:
    # - Validating file existence
    # - Preparing files for API submission
    # - Converting different file input types (String paths, File objects, IO streams)
    # - File format and size validation is delegated to the platform and Truedocs service
    #
    # @example
    #   handler = Truedocs::Utils::FileHandler.new("path/to/document.pdf")
    #   prepared_file = handler.prepare
    #
    # @example
    #   handler = Truedocs::Utils::FileHandler.new(File.open("document.pdf"))
    #   prepared_file = handler.prepare
    class FileHandler
      def initialize(file)
        @file = file
      end

      def prepare
        validate_file!

        case @file
        when String
          prepare_file_path(@file)
        when File, IO
          prepare_file_object(@file)
        when Hash
          @file # Already prepared multipart data
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{@file.class}"
        end
      end

      private

      def validate_file!
        case @file
        when String
          validate_file_path(@file)
        when File, IO
          validate_file_object(@file)
        when Hash
          # Assume it's already prepared multipart data
          nil
        else
          raise UnsupportedFileTypeError, "Unsupported file type: #{@file.class}"
        end
      end

      def validate_file_path(path)
        raise ValidationError, "File does not exist: #{path}" unless File.exist?(path)
      end

      def validate_file_object(file)
        # Basic validation to ensure the file object is readable
        file.rewind if file.respond_to?(:rewind)
        file.read(0) # Test readability without consuming content
        file.rewind if file.respond_to?(:rewind)
      end

      def prepare_file_path(path)
        Faraday::UploadIO.new(path, Marcel::MimeType.for(Pathname.new(path)))
      end

      def prepare_file_object(file)
        file.rewind if file.respond_to?(:rewind)
        content = file.read
        file.rewind if file.respond_to?(:rewind)

        mime_type = Marcel::MimeType.for(content)
        filename = file.respond_to?(:path) ? File.basename(file.path) : "file"

        Faraday::UploadIO.new(StringIO.new(content), mime_type, filename)
      end
    end
  end
end
