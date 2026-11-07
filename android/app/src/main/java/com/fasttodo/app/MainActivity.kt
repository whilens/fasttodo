package com.fasttodo.app

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.LinearEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay

private val Indigo = Color(0xFF4F46E5)
private val SplashBg = Color(0xFF111827)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val store = TodoStore(this)
        setContent {
            MaterialTheme(
                colorScheme = lightColorScheme(primary = Indigo),
            ) {
                Surface(modifier = Modifier.fillMaxSize()) {
                    AppRoot(store = store)
                }
            }
        }
    }
}

@Composable
private fun AppRoot(store: TodoStore) {
    var showSplash by remember { mutableStateOf(true) }

    LaunchedEffect(Unit) {
        delay(2200)
        showSplash = false
    }

    AnimatedContent(
        targetState = showSplash,
        transitionSpec = {
            (fadeIn(tween(450)) + scaleIn(initialScale = 0.96f, animationSpec = tween(450)))
                .togetherWith(fadeOut(tween(280)))
        },
        label = "splash",
    ) { splash ->
        if (splash) {
            LoadingSplash()
        } else {
            TodoScreen(store = store)
        }
    }
}

@Composable
private fun LoadingSplash() {
    val infinite = rememberInfiniteTransition(label = "splash")
    val rotation by infinite.animateFloat(
        initialValue = 0f,
        targetValue = 360f,
        animationSpec = infiniteRepeatable(
            animation = tween(1100, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "rotation",
    )
    val pulse by infinite.animateFloat(
        initialValue = 0.86f,
        targetValue = 1.12f,
        animationSpec = infiniteRepeatable(
            animation = tween(700, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "pulse",
    )
    val titleAlpha by infinite.animateFloat(
        initialValue = 0.55f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(900),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "title",
    )

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(SplashBg),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                modifier = Modifier
                    .size(112.dp)
                    .scale(pulse),
                contentAlignment = Alignment.Center,
            ) {
                Canvas(
                    modifier = Modifier
                        .matchParentSize()
                        .rotate(rotation),
                ) {
                    drawArc(
                        color = Indigo,
                        startAngle = -90f,
                        sweepAngle = 260f,
                        useCenter = false,
                        style = Stroke(width = 10.dp.toPx(), cap = StrokeCap.Round),
                        size = Size(size.minDimension, size.minDimension),
                        topLeft = Offset.Zero,
                    )
                }
                Box(
                    modifier = Modifier
                        .size(64.dp)
                        .background(Indigo, CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(text = "✓", color = Color.White, style = MaterialTheme.typography.headlineMedium)
                }
            }
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                text = "FastTodo",
                color = Color.White,
                style = MaterialTheme.typography.headlineLarge,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.alpha(titleAlpha),
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = "Собираем ваши задачи…", color = Color(0xFFCBD5E1))
        }
    }
}

@Composable
private fun TodoScreen(store: TodoStore) {
    val context = LocalContext.current
    var tasks by remember { mutableStateOf(store.load()) }
    var text by remember { mutableStateOf("") }
    var buttonScale by remember { mutableFloatStateOf(1f) }
    val animatedButtonScale by animateFloatAsState(
        targetValue = buttonScale,
        animationSpec = spring(dampingRatio = 0.35f, stiffness = Spring.StiffnessMedium),
        label = "add-button",
    )

    fun persist(next: List<Todo>) {
        tasks = next
        store.save(next)
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        Text(text = "Задачи", style = MaterialTheme.typography.headlineMedium)

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            OutlinedTextField(
                value = text,
                onValueChange = { text = it },
                modifier = Modifier.weight(1f),
                placeholder = { Text("Новая задача") },
                singleLine = true,
            )
            Button(
                modifier = Modifier.scale(animatedButtonScale),
                onClick = {
                    val title = text.trim()
                    if (title.isEmpty()) return@Button
                    persist(listOf(Todo(id = System.currentTimeMillis(), title = title)) + tasks)
                    text = ""
                    buttonScale = 0.82f
                    vibrate(context)
                },
            ) {
                Text("Добавить")
            }
        }

        LaunchedEffect(buttonScale) {
            if (buttonScale != 1f) {
                delay(90)
                buttonScale = 1f
            }
        }

        AnimatedVisibility(
            visible = tasks.isEmpty(),
            enter = fadeIn(),
            exit = fadeOut(),
        ) {
            Text("Пока нет задач")
        }

        LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            itemsIndexed(tasks, key = { _, task -> task.id }) { index, task ->
                TodoRow(
                    task = task,
                    index = index,
                    onDelete = { persist(tasks.filter { it.id != task.id }) },
                    modifier = Modifier.animateItem(
                        fadeInSpec = tween(280),
                        fadeOutSpec = tween(220),
                        placementSpec = spring(
                            dampingRatio = Spring.DampingRatioMediumBouncy,
                            stiffness = Spring.StiffnessLow,
                        ),
                    ),
                )
            }
        }
    }
}

@Composable
private fun TodoRow(
    task: Todo,
    index: Int,
    onDelete: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var shown by remember { mutableStateOf(false) }

    LaunchedEffect(task.id) {
        delay(index.coerceAtMost(8) * 45L)
        shown = true
    }

    val offsetX by animateDpAsState(
        targetValue = if (shown) 0.dp else 48.dp,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
        label = "row-x",
    )
    val alpha by animateFloatAsState(
        targetValue = if (shown) 1f else 0f,
        animationSpec = tween(320),
        label = "row-alpha",
    )
    val scale by animateFloatAsState(
        targetValue = if (shown) 1f else 0.92f,
        animationSpec = spring(dampingRatio = 0.55f),
        label = "row-scale",
    )

    Card(
        modifier = modifier
            .fillMaxWidth()
            .offset(x = offsetX)
            .scale(scale)
            .alpha(alpha),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFFF8FAFC)),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 14.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = task.title,
                modifier = Modifier
                    .weight(1f)
                    .padding(end = 8.dp),
                style = MaterialTheme.typography.bodyLarge,
            )
            OutlinedButton(onClick = onDelete) {
                Text("Удалить")
            }
        }
    }
}

private fun vibrate(context: Context) {
    val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        context.getSystemService(VibratorManager::class.java).defaultVibrator
    } else {
        context.getSystemService(Vibrator::class.java)
    }

    vibrator.vibrate(
        VibrationEffect.createOneShot(50, VibrationEffect.DEFAULT_AMPLITUDE),
    )
}
