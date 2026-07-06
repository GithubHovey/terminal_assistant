#include "ImageProcessor.h"
#include <QImage>
#include <QPainter>
#include <QPainterPath>
#include <QFileInfo>
#include <QDir>
#include "src/backend/logger/Logger.h"

ImageProcessor::ImageProcessor(QObject *parent)
    : QObject(parent)
{
}

ImageProcessor::~ImageProcessor() = default;

bool ImageProcessor::cropCircular(const QString &inputPath,
                                  const QString &outputPath,
                                  int targetSize,
                                  int offsetX, int offsetY,
                                  double scale,
                                  int previewSize)
{
    if (inputPath.isEmpty() || outputPath.isEmpty() || targetSize <= 0) {
        emit processingError("Invalid parameters");
        return false;
    }

    QImage input(inputPath);
    if (input.isNull()) {
        emit processingError("Failed to load image: " + inputPath);
        return false;
    }

    // Ensure output directory exists
    QFileInfo outputInfo(outputPath);
    QDir().mkpath(outputInfo.absolutePath());

    // Create output image with transparency
    QImage output(targetSize, targetSize, QImage::Format_ARGB32_Premultiplied);
    output.fill(Qt::transparent);

    QPainter painter(&output);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setRenderHint(QPainter::SmoothPixmapTransform);

    // Create circular clip path
    QPainterPath clipPath;
    clipPath.addEllipse(0, 0, targetSize, targetSize);
    painter.setClipPath(clipPath);

    // Calculate the scale to fill preview area (matching QML's PreserveAspectCrop)
    double previewScale = qMax(static_cast<double>(previewSize) / input.width(),
                               static_cast<double>(previewSize) / input.height());
    
    // Total scale = preview scale * user scale
    double totalScale = previewScale * scale;

    // Calculate scaled image dimensions
    double scaledW = input.width() * totalScale;
    double scaledH = input.height() * totalScale;

    // Calculate the position of the scaled image relative to the preview
    // The scaled image is centered in the preview, then offset by (offsetX, offsetY)
    double imgX = (previewSize - scaledW) / 2.0 + offsetX;
    double imgY = (previewSize - scaledH) / 2.0 + offsetY;

    // The top-left corner of the preview in the scaled image coordinates
    double srcX = -imgX;
    double srcY = -imgY;

    // Map the source rectangle to the original image coordinates
    double origSrcX = srcX / totalScale;
    double origSrcY = srcY / totalScale;
    double origSrcW = previewSize / totalScale;
    double origSrcH = previewSize / totalScale;

    QRectF sourceRect(origSrcX, origSrcY, origSrcW, origSrcH);
    QRectF targetRect(0, 0, targetSize, targetSize);

    Logger::instance().logInfo(QString("Crop: input=%1x%2, previewScale=%3, totalScale=%4, offset=(%5,%6), sourceRect=(%7,%8,%9,%10)")
        .arg(input.width()).arg(input.height())
        .arg(previewScale, 0, 'f', 2).arg(totalScale, 0, 'f', 2)
        .arg(offsetX).arg(offsetY)
        .arg(origSrcX, 0, 'f', 1).arg(origSrcY, 0, 'f', 1)
        .arg(origSrcW, 0, 'f', 1).arg(origSrcH, 0, 'f', 1));

    // Draw the source rectangle to the target rectangle
    painter.drawImage(targetRect, input, sourceRect);

    painter.end();

    // Save as PNG
    if (!output.save(outputPath, "PNG")) {
        emit processingError("Failed to save image: " + outputPath);
        return false;
    }

    Logger::instance().logInfo("Circular crop completed: " + outputPath);
    emit processingFinished(outputPath);
    return true;
}

bool ImageProcessor::cropRectangular(const QString &inputPath,
                                     const QString &outputPath,
                                     int targetWidth, int targetHeight,
                                     int offsetX, int offsetY,
                                     double scale,
                                     int previewWidth,
                                     int previewHeight)
{
    if (inputPath.isEmpty() || outputPath.isEmpty() || 
        targetWidth <= 0 || targetHeight <= 0) {
        emit processingError("Invalid parameters");
        return false;
    }

    QImage input(inputPath);
    if (input.isNull()) {
        emit processingError("Failed to load image: " + inputPath);
        return false;
    }

    // Ensure output directory exists
    QFileInfo outputInfo(outputPath);
    QDir().mkpath(outputInfo.absolutePath());

    // Create output image with transparency
    QImage output(targetWidth, targetHeight, QImage::Format_ARGB32_Premultiplied);
    output.fill(Qt::transparent);

    QPainter painter(&output);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setRenderHint(QPainter::SmoothPixmapTransform);

    // Calculate the scale to fill preview area (matching QML's PreserveAspectCrop)
    double previewScaleX = static_cast<double>(previewWidth) / input.width();
    double previewScaleY = static_cast<double>(previewHeight) / input.height();
    double previewScale = qMax(previewScaleX, previewScaleY);
    
    // Total scale = preview scale * user scale
    double totalScale = previewScale * scale;

    // Calculate scaled image dimensions
    double scaledW = input.width() * totalScale;
    double scaledH = input.height() * totalScale;

    // Calculate the position of the scaled image relative to the preview
    double imgX = (previewWidth - scaledW) / 2.0 + offsetX;
    double imgY = (previewHeight - scaledH) / 2.0 + offsetY;

    // The top-left corner of the preview in the scaled image coordinates
    double srcX = -imgX;
    double srcY = -imgY;

    // Map the source rectangle to the original image coordinates
    double origSrcX = srcX / totalScale;
    double origSrcY = srcY / totalScale;
    double origSrcW = previewWidth / totalScale;
    double origSrcH = previewHeight / totalScale;

    QRectF sourceRect(origSrcX, origSrcY, origSrcW, origSrcH);
    QRectF targetRect(0, 0, targetWidth, targetHeight);

    // Draw the source rectangle to the target rectangle
    painter.drawImage(targetRect, input, sourceRect);

    painter.end();

    // Save as PNG
    if (!output.save(outputPath, "PNG")) {
        emit processingError("Failed to save image: " + outputPath);
        return false;
    }

    Logger::instance().logInfo("Rectangular crop completed: " + outputPath);
    emit processingFinished(outputPath);
    return true;
}
