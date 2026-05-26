import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'enemy.dart'; // Certifique-se de que o nome do arquivo do seu inimigo está correto

class AttackArea extends PositionComponent with CollisionCallbacks {
  AttackArea({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  // Mudamos para onCollision para checar continuamente e eliminar grupos de inimigos de uma vez só
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    // Substitua 'Enemy' pelo nome real da classe do seu inimigo se for diferente
    if (other is Enemy) {
      other.removeFromParent(); 
    }
  }
}